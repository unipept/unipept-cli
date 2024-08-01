export class TestObject {
  static testObject() {
    return { "integer": 5, "string": "string", "list": ["a", 2, false] };
  }

  static asJson() {
    return '{"integer":5,"string":"string","list":["a",2,false]}';
  }

  static asXml() {
    return '<integer>5</integer><string>string</string><list><item>a</item><item>2</item><item>false</item></list>';
  }

  static asCsv() {
    return '5,string,"[""a"",2,false]"';
  }

  static asCsvHeader() {
    return "integer,string,list\n";
  }
}
