// Mocked API responses
export const pept2protResponse = [
  {"peptide":"AALTER","uniprot_id":"A0ABS7GN52","protein_name":"AAA family ATPase","taxon_id":335017,"protein":"MQLKMPTPNGGLAIEAVPGKPIIFLGPNGTGKSRLGIYLDDLDSSSPSHRISAQRSLELPDEIFTDRYDRAIEMLRRDKSVKRTRTSPGSMEFDYDQLLIALFAERRRALEQAHEKSQGKTKSVRPVTAIDRLQLLWTELVPHQKLQFSESTVLALRTDYHDEAYEASEMSDGERFVLYLLGQVLLLEHAGLIIVDEPELHMSRALLGRLWDLAEQCRPDCAFIYITHDIDFASTRRNAQMYAVLNYMPPTYEEVRVRTRTKLVEATPPIWTIHALPSITDLPRDVLVRMVGSRKPILFVEGKAGGLDELLYKSAYSDFTVIATGSCAQVIQLVRSFRGQSSLHWLHCAGLVDLDNRTTDEYGAIDDAIYALPVQEVENLLLVSEVFLELAKALSFDADDAARQLERLKIDVLSSAARRADAISLKYTSHRIWEAGKSIGLKAQTIEELAKLHSDITARTDPTAIYNDFRASFEAALTERNYTKILALDDNKNGLLDLLGKSLGLQGRSAIESFITRTLNSPAGAGLVQALRSQLPGIDATAL"},
  {"peptide":"AALTER","uniprot_id":"A0AA41UKX0","protein_name":"Efflux RND transporter periplasmic adaptor subunit","taxon_id":2929485,"protein":"MKRNIAIGIGAAVLLLLVWQLWSHFSTGRDEAGQPRAVRPVAVEVVPVRRADMRDVATFTGTLLPTSRFEVAPKIAGRLEKILVHIGDAVAPGQLVAVLDDEEYRQQVSQARAELEVARASLEEAITTLESSRREFERTVALHRQRIASESQLDAAESEYNALQARMRVAAAQVAQREATLRLAEVRLAYTRIHVPESNGVQRVVGERFVDEGALLSANTPIVSVLDIRRLNAVVHVIERDYARITPDLTAVVTTDAFPGRTFTGRVARIAPLLKETSRQARVEIEVPNPAMELKPGMFVRAHIEFAEYADATVVPLSALVTRGGQRGVFLADRDAGTARFVSVTVGITEGDLAQVLTPQLEGEVVTLGVHLVVDGAAISIPESRSTAALTERP"}
];

export const pept2taxaResponse = [
  {"peptide":"AALTER","taxon_id":46180,"taxon_name":"Nonomuraea rubra","taxon_rank":"species"},
  {"peptide":"AALTER","taxon_id":2172121,"taxon_name":"Pararhodobacter oceanensis","taxon_rank":"species"},
  {"peptide":"AALTER","taxon_id":2932258,"taxon_name":"Halobacillus shinanisalinarum","taxon_rank":"species"}
];

export const pept2lcaResponse = [
  {"peptide":"AALTER","taxon_id":1,"taxon_name":"root","taxon_rank":"no rank"}
];

export const peptinfoResponse = [
  {"peptide":"AALTER","total_protein_count":1669,"taxon_id":1,"taxon_name":"root","taxon_rank":"no rank","ec_number":"3.1.3.16","ec_protein_count":3,"go_term":"GO:0006233","go_protein_count":2,"ipr_code":"IPR000008","ipr_protein_count":8}
];

export const pept2ecResponse = [
  {
    "peptide": "AALTER",
    "total_protein_count": 1669,
    "ec": [
        {"ec_number":"2.1.1.74","protein_count":1},
        {"ec_number":"6.1.1.15","protein_count":1},
        {"ec_number":"2.7.4.2","protein_count":1},
        {"ec_number":"2.3.2.27","protein_count":15}
    ]
  }
];

export const pept2goResponse = [
  {
    "peptide": "AALTER",
    "total_protein_count": 1669,
    "go": [
        {"go_term":"GO:0006233","protein_count":2},
        {"go_term":"GO:0004416","protein_count":3},
        {"go_term":"GO:0001733","protein_count":1},
        {"go_term":"GO:0003677","protein_count":1}
    ]
  }
];

export const pept2interproResponse = [
  {
    "peptide": "AALTER",
    "total_protein_count": 1669,
    "ipr": [
        {"code":"IPR003753","protein_count":3},
        {"code":"IPR050988","protein_count":1},
        {"code":"IPR001270","protein_count":4},
        {"code":"IPR003613","protein_count":11}
    ]
  }
];

export const pept2functResponse = [
    {"peptide":"AALTER","total_protein_count":1669,"ec_number":"3.1.3.16","ec_protein_count":3,"go_term":"GO:0006233","go_protein_count":2,"ipr_code":"IPR000008","ipr_protein_count":8}
];

export const taxa2lcaResponse = {
  "taxon_id":1678,"taxon_name":"Bifidobacterium","taxon_rank":"genus"
};

export const taxonomyResponse = [
  {"taxon_id":216816,"taxon_name":"Bifidobacterium longum","taxon_rank":"species"}
];

export const protinfoResponse = [
  {"protein":"P78330","name":"Phosphoserine phosphatase","taxon_id":9606,"taxon_name":"Homo sapiens","taxon_rank":"species","ec":[{"ec_number":"3.1.3.3"}],"go":[{"go_term":"GO:0005737"},{"go_term":"GO:0005829"},{"go_term":"GO:0042802"},{"go_term":"GO:0036424"},{"go_term":"GO:0000287"},{"go_term":"GO:0042803"},{"go_term":"GO:0001701"},{"go_term":"GO:0006564"},{"go_term":"GO:0006563"},{"go_term":"GO:0009612"},{"go_term":"GO:0031667"},{"go_term":"GO:0033574"}],"ipr":[{"code":"IPR050582"},{"code":"IPR036412"},{"code":"IPR023214"},{"code":"IPR004469"}]}
];
