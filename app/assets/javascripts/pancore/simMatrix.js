/**
 * Creates a SimMatrix object that includes the similarity matrix and
 * phylogenetic tree.
 *
 * @param <Worker> args.worker The Worker object processing the data
 * @param <GenomeTable> args.table The GenomeTable object
 */
var constructSimMatrix = function constructSimMatrix(args) {
    /*************** Private variables ***************/

    // Parameters
    var worker = args.worker,
        table = args.table;

    // UI variables
    var margin = {top: 20, right: 0, bottom: 200, left: 200},
        width = 500,
        height = 500;

    // variable to contain our d3 selectors
    var svg;

    // Scales
    var x = d3.scale.ordinal().rangeBands([0, width]),
        z = d3.scale.linear().domain([0, 1]).clamp(true);

    // Constructor fields
    var names = [],
        order = [],
        oldDomain = [],
        treeOrder = [],
        matrix = [],
        clustered = undefined,
        updated = false,
        newick;

    var $tabSelector = $('a[href="#sim_matrix_wrapper"]'),
        $graphSelector = $('#sim_graph'),
        $clusterBtn;

    var that = {};

    /*************** Private methods ***************/

    /**
     * Initializes the SimMatrix
     */
    function init() {
        setupWorker();
        $tabSelector.on('shown.bs.tab', function tabSwitchAction() {
            that.calculateSimilarity();
            that.redraw();
        });
        $clusterBtn = $("#cluster-matrix-btn");
        $clusterBtn.click(function clusterButtonAction() {
            that.clusterMatrix();
        });

        $('#sim_matrix').mouseout(function mouseOutAction() {
            $('#matrix-popover-table').html('');
        });

        x.domain([]);

        $('#decluster-matrix').click(function declusterAction() {
            x.domain(oldDomain);
            updated = true;
            that.setClustered(false);
            that.redraw();
        });

        $('#use-cluster-order').click(reorderTable);

        // Dummy newick value chosen randomly
        var dummyNewick = "((((A:0.2,B:0.2):0.1,C:0.3):0.4,(F:0.4,D:0.4):0.3):0.3,E:1.0)";
        that.drawTree(dummyNewick, 500);
    }

    /**
     * Generate a row
     *
     * @param <?> row TODO
     */
    function rowF(row) {
        var cell = d3.select(this).selectAll(".cell")
            .data(row)
            .attr("x", function (d, i) { return x(i); })
            .attr("width", x.rangeBand())
            .attr("height", x.rangeBand())
            .style("fill-opacity", function (d) { return z(d * d); })
            .style("fill", function (d) { return (d != -1) ? "steelblue" : "white"; })
          .enter().append("rect")
            .attr("class", "cell")
            .attr("x", function (d, i) { return x(i); })
            .attr("width", x.rangeBand())
            .attr("height", x.rangeBand())
            .style("fill-opacity", function (d) { return z(d * d); })
            .style("fill", function (d) { return (d != -1) ? "steelblue" : "white"; });
    }

    /**
     * Add popover to all cells
     *
     * @param <?> row TODO
     * @param <?> j TODO
     */
    function popOverF(row, j) {
        d3.select(this).selectAll(".cell")
            .each(function (d, i) {
                var first = names[order[i]];
                var second = names[order[j]];
                var content = d >= 0 ? d3.format(".2%")(d) : "Not calculated";
                var table = "";
                if (d >= 0) {
                    table += "<table class='table'><thead><tr><th></th><th>" + first.name + "</th><th>" + second.name + "</th></tr></thead>";
                    table += "<tr><td>Core Peptides</td><td>" + first.core + "</td><td>" + second.core + "</td></tr>";
                    table += "<tr><td>Pan Peptides</td><td>" + first.pan + "</td><td>" + second.pan + "</td></tr>";
                    table += "<tr><td>Peptidome Similarity</td><td colspan='2' align='center'>" + content + "</td></tr></table>";
                }
                $(this).hover(function () {
                    $('#matrix-popover-table').html(table);
                });
            });
    }

    /* TODO: can this be abstracted? */
    function sendToWorker(type, message) {
        worker.postMessage({'cmd': type, 'msg': message});
    }

    function setupWorker() {
        /* setup worker */
        worker.addEventListener('message', function (e) {
            var data = e.data;
            switch (data.type) {
            case 'newOrder':
                that.reorder(data.msg);
                break;
            case 'matrixData':
                receiveMatrix(data.msg);
                break;
            case 'newick':
                that.drawTree(data.msg);
                break;
            case 'reorderTable':
                reorderTable();
                break;
            case 'log':
                console.log(data.msg);
                break;
            }
        });
    }

    /**
     * Receive the new matrix from the worker
     *
     * @param <?> m TODO
     */
    function receiveMatrix(m) {
        var i;

        if (m.index === 'all') {
            matrix = m.data;
        } else {
            matrix[m.index] = m.data;
            for (i = 0; i < order.length; i++) {
                matrix[i][m.index] = m.data[i];
            }
        }
        updated = true;
        that.redraw();
    }

    /**
     * Calculate height needed for matrix
     */
    function setMinWidth() {
        var min_width = d3.min([width, 50 * matrix.length]);
        x.rangeBands([0, min_width]);
        return min_width;
    }

    /**
     * TODO
     */
    function reorderTable() {
        var clusterOrder = [],
            domain = x.domain(),
            i;
        for (i = 0; i < order.length; i++) {
            clusterOrder.push(order[domain[i]]);
        }
        sendToWorker("recalculatePanCore", {'order': clusterOrder, start: 0, end: clusterOrder.length - 1});
        table.setOrder(clusterOrder);
        $('#reorder-header').addClass('hidden');
    }

    /*************** Public methods ***************/

    /**
     * Reorder the matrix based on the new order
     *
     * @param <?> newOrder TODO
     */
    that.reorder = function reorder(newOrder) {
        treeOrder = newOrder;
        oldDomain = x.domain().slice(0);
        x.domain(newOrder);

        setMinWidth();

        that.setClustered(true);

        var t = svg.transition().duration(1000);

        t.selectAll(".row")
            .delay(function (d, i) { return x(i) * 2; })
            .attr("transform", function (d, i) { return "translate(0," + x(i) + ")"; })
            .selectAll(".cell")
            .delay(function (d, i) { return x(i) * 2; })
            .attr("x", function (d, i) { return x(i); });

        t.selectAll(".column")
            .delay(function (d, i) { return x(i) * 2; })
            .attr("transform", function (d, i) { return "translate(" + x(i) + ")rotate(90)"; });
        updated = true;
    };

    /**
     * TODO
     *
     * @param <?> orderData TODO
     */
    that.updateOrder = function updateOrder(orderData) {
        var newDomain = [],
            i;
        for (i = 0; i < order.length; i++) {
            newDomain.push(order.indexOf(orderData[i]));
        }
        x.domain(newDomain);

        that.setClustered(false);
        updated = true;
        that.redraw();
    };

    /**
     * TODO
     *
     * @param <?> removed TODO
     */
    that.redraw = function redraw(removed) {
        // Check if we are currently active pane
        if (!that.activeTab() || !updated) {
            return;
        }

        updated = false;
        if (removed) {
            $("#sim_matrix").html('');
        }

        if (!svg || removed) {
            svg = d3.select("#sim_matrix").append("svg")
                .attr("width", width + margin.left + margin.right)
                .attr("height", height + margin.top + margin.bottom)
                .append("g")
                .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

            svg.append("rect")
                .attr("class", "background")
                .attr("width", width)
                .attr("height", height)
                .attr("fill", "#eeeeee");

        }

        /* allow for smaller scale matrices */
        var min_width = setMinWidth();
        d3.select(".background")
            .attr("width", min_width)
            .attr("height", min_width);

        var row = svg.selectAll(".row")
            .data(matrix);

        row.attr("transform", function (d, i) { return "translate(0," + x(i) + ")"; })
            .each(rowF);

        row.selectAll("text").attr('y', x.rangeBand() / 2);

        row_enter = row.enter().append("g")
            .attr("class", "row")
            .attr("transform", function (d, i) { return "translate(0," + x(i) + ")"; })
            .each(rowF);

        row_enter.append("text")
            .attr("x", -6)
            .attr("y", x.rangeBand() / 2)
            .attr("dy", ".32em")
            .attr("text-anchor", "end")
            .text(function (d, i) { return names[order[i]].name; });

        var column = svg.selectAll(".column")
            .data(matrix)
            .attr("transform", function (d, i) { return "translate(" + x(i) + ")rotate(90)"; })
            .attr("y", x.rangeBand() / 2);

        column.selectAll("text")
            .attr("x", min_width + 6)
            .attr('y', -x.rangeBand() / 2);

        column_enter = column.enter().append("g")
            .attr("class", "column")
            .attr("transform", function (d, i) { return "translate(" + x(i) + ")rotate(90)"; });

        column_enter.append("text")
            .attr("x", min_width + 6)
            .attr("y", -x.rangeBand() / 2)
            .attr("dy", ".32em")
            .attr("text-anchor", "start")
            .text(function (d, i) { return names[order[i]].name; });

        row.each(popOverF);
    };

    /**
     * TODO
     */
    that.clearAllData = function clearAllData() {
        updated = true;
        that.setClustered(false);
        matrix = [];
        order = [];
        names = [];
        treeOrder = [];
        newick = "";
        x.domain([]);
        that.redraw(true);
    };

    /**
     * TODO
     *
     * @param <?> c TODO
     */
    that.setClustered = function setClustered(c) {
        /* check if value differs, if we don't do this we call fadeTo too many times" */
        var minWidth = setMinWidth();
        if (c != clustered) {
            if (!c) {
                $graphSelector.fadeTo('normal', 0.2);
                $clusterBtn.show();
                $('#reorder-header').addClass('hidden');
            } else {
                $graphSelector.fadeTo('fast', 1);
                $clusterBtn.hide();
                $('#reorder-header').removeClass('hidden');
                $('#cluster-div').css('height', minWidth + 30 + "px");
                $('#matrix-popover-table').css('top', minWidth + 20 + 'px');
            }
            clustered = c;
        }

    };

    /**
     * TODO
     *
     * @param <?> n TODO
     * @param <?> height TODO
     */
    that.drawTree = function drawTree(n, height) {
        newick = n;
        var parsed = Newick.parse(n);
        $("#sim_graph").html("");
        var min_height;
        if (height === undefined) {
            min_height = d3.min([500, 50 * matrix.length]);
        } else {
            min_height = height;
        }

        d3.phylogram.build('#sim_graph', parsed, {width: 180, height: min_height, skipLabels: true}, treeOrder);
    };

    /**
     * Calculate similarity
     */
    that.calculateSimilarity = function calculateSimilarity() {
        if (updated) {
            sendToWorker('calculateSimilarity');
        }
    };

    /**
     * TODO
     */
    that.clusterMatrix = function clusterMatrix() {
        sendToWorker('clusterMatrix');
    };

    /**
     * Add data to the matrix
     *
     * @param <?> id TODO
     * @param <?> name TODO
     * @param <?> core TODO
     * @param <?> pan TODO
     */
    that.addGenome = function addGenome(id, name, core, pan) {
        var length,
            i;

        names[id] = {'name': name, 'core': core, 'pan': pan};
        order.push(id);
        length = matrix.length;
        for (i = 0; i < length; i++) {
            // add -1 to the end
            matrix[i].push(-1);
        }

        var new_row = [];
        for (i = 0; i < order.length; i++) {
            new_row.push(-1);
        }
        matrix.push(new_row);

        that.setClustered(false);
        updated = true;
        if (that.activeTab()) {
            that.calculateSimilarity();
        }

        that.redraw();
    };

    /**
     * Remove data from the matrix
     *
     * @param <?> id TODO
     */
    that.removeGenome = function removeGenome(id) {
        delete names[id];
        var index = order.indexOf(id),
            i;
        order.splice(index, 1);

        matrix.splice(index, 1);
        for (i = 0; i < matrix.length; i++) {
            // add -1 to the end
            matrix[i].splice(index, 1);
        }

        that.setClustered(false);
        updated = true;
        that.redraw(true);
    };

    /**
     * TODO
     */
    that.activeTab = function activeTab() {
        return $tabSelector.parent().hasClass("active");
    };

    /**
     * TODO
     */
    that.getDataAsCsv = function getDataAsCsv() {
        var csvString = ",",
            tempArray = [],
            i;

        for (i = 0; i < order.length; i++) {
            tempArray.push('"' + names[order[i]].name + '"');
        }
        csvString += tempArray.join(',') + "\n";

        for (i = 0; i < order.length; i++) {
            tempArray = [];
            tempArray.push('"' + names[order[i]].name + '"');
            tempArray.push.apply(tempArray, matrix[i]);
            csvString += tempArray.join(',') + "\n";
        }

        return csvString;
    };

    // Initialize the object
    init();

    return that;
};
