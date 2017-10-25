describe "Less grammar", ->
  grammar = null

  beforeEach ->
    waitsForPromise ->
      atom.packages.activatePackage("language-css")

    waitsForPromise ->
      atom.packages.activatePackage("language-less")

    runs ->
      grammar = atom.grammars.grammarForScopeName("source.css.less")

  it "parses the grammar", ->
    expect(grammar).toBeDefined()
    expect(grammar.scopeName).toBe "source.css.less"

  it "parses numbers", ->
    {tokens} = grammar.tokenizeLine(" 10")
    expect(tokens).toHaveLength 2
    expect(tokens[0]).toEqual value: " ", scopes: ['source.css.less']
    expect(tokens[1]).toEqual value: "10", scopes: ['source.css.less', 'constant.numeric.css']

    {tokens} = grammar.tokenizeLine("-.1")
    expect(tokens).toHaveLength 1
    expect(tokens[0]).toEqual value: "-.1", scopes: ['source.css.less', 'constant.numeric.css']

    {tokens} = grammar.tokenizeLine(".4")
    expect(tokens).toHaveLength 1
    expect(tokens[0]).toEqual value: ".4", scopes: ['source.css.less', 'constant.numeric.css']

  it 'parses color names', ->
    {tokens} = grammar.tokenizeLine '.foo { color: rebeccapurple; background: whitesmoke; }'
    expect(tokens[8]).toEqual value: "rebeccapurple", scopes: ['source.css.less', 'meta.property-list.css', 'meta.property-value.css', 'support.constant.color.w3c-extended-color-name.css']
    expect(tokens[14]).toEqual value: "whitesmoke", scopes: ['source.css.less', 'meta.property-list.css', 'meta.property-value.css', 'support.constant.color.w3c-extended-color-name.css']

  it "parses property names", ->
    {tokens} = grammar.tokenizeLine("{display: none;}")
    expect(tokens[1]).toEqual value: "display", scopes: ['source.css.less', 'meta.property-list.css', 'support.type.property-name.css']

    {tokens} = grammar.tokenizeLine("{displaya: none;}")
    expect(tokens[1]).toEqual value: "displaya", scopes: ['source.css.less', 'meta.property-list.css']

  it "parses property names distinctly from property values with the same text", ->
    {tokens} = grammar.tokenizeLine("{left: left;}")
    expect(tokens).toHaveLength 7
    expect(tokens[1]).toEqual value: "left", scopes: ['source.css.less', 'meta.property-list.css', 'support.type.property-name.css']
    expect(tokens[2]).toEqual value: ":", scopes: ['source.css.less', 'meta.property-list.css', 'punctuation.separator.key-value.css']
    expect(tokens[3]).toEqual value: " ", scopes: ['source.css.less', 'meta.property-list.css']
    expect(tokens[4]).toEqual value: "left", scopes: ['source.css.less', 'meta.property-list.css', 'meta.property-value.css', 'support.constant.property-value.css']
    expect(tokens[5]).toEqual value: ";", scopes: ['source.css.less', 'meta.property-list.css', 'punctuation.terminator.rule.css']

    {tokens} = grammar.tokenizeLine("{left:left;}")
    expect(tokens).toHaveLength 6
    expect(tokens[1]).toEqual value: "left", scopes: ['source.css.less', 'meta.property-list.css', 'support.type.property-name.css']
    expect(tokens[2]).toEqual value: ":", scopes: ['source.css.less', 'meta.property-list.css', 'punctuation.separator.key-value.css']
    expect(tokens[3]).toEqual value: "left", scopes: ['source.css.less', 'meta.property-list.css', 'meta.property-value.css', 'support.constant.property-value.css']
    expect(tokens[4]).toEqual value: ";", scopes: ['source.css.less', 'meta.property-list.css', 'punctuation.terminator.rule.css']

  it "parses property names distinctly from element selectors with the same prefix", ->
    {tokens} = grammar.tokenizeLine("{table-layout: fixed;}")
    expect(tokens).toHaveLength 7
    expect(tokens[1]).toEqual value: "table-layout", scopes: ['source.css.less', 'meta.property-list.css', 'support.type.property-name.css']
    expect(tokens[2]).toEqual value: ":", scopes: ['source.css.less', 'meta.property-list.css', 'punctuation.separator.key-value.css']
    expect(tokens[3]).toEqual value: " ", scopes: ['source.css.less', 'meta.property-list.css']
    expect(tokens[4]).toEqual value: "fixed", scopes: ['source.css.less', 'meta.property-list.css', 'meta.property-value.css', 'support.constant.property-value.css']
    expect(tokens[5]).toEqual value: ";", scopes: ['source.css.less', 'meta.property-list.css', 'punctuation.terminator.rule.css']

  it "does not parse @media conditions as a property-list", ->
    {tokens} = grammar.tokenizeLine('@media (min-resolution: 2dppx) {}')
    expect(tokens[4].scopes).not.toContain 'support.type.property-name.css'
    expect(tokens[7].scopes).not.toContain 'meta.property-value.css'
    expect(tokens[11].scopes).not.toContain 'meta.property-value.css'

  it "parses @media features", ->
    {tokens} = grammar.tokenizeLine('@media (min-width: 100px) {}')
    expect(tokens[0]).toEqual value: "@", scopes: ['source.css.less', 'meta.at-rule.media.css', 'keyword.control.at-rule.media.css', 'punctuation.definition.keyword.css']
    expect(tokens[1]).toEqual value: "media", scopes: ['source.css.less', 'meta.at-rule.media.css', 'keyword.control.at-rule.media.css']
    expect(tokens[4]).toEqual value: "min-width", scopes: ['source.css.less', 'support.type.property-name.media.css']
    expect(tokens[7]).toEqual value: "100", scopes: ['source.css.less', 'constant.numeric.css']
    expect(tokens[8]).toEqual value: "px", scopes: ['source.css.less', 'constant.numeric.css', 'keyword.other.unit.px.css']

  it "parses @media orientation", ->
    {tokens} = grammar.tokenizeLine('@media (orientation: portrait){}')
    expect(tokens[4]).toEqual value: "orientation", scopes: ['source.css.less', 'support.type.property-name.media.css']
    expect(tokens[7]).toEqual value: "portrait", scopes: ['source.css.less', 'support.constant.property-value.media-property.media.css']

  it "parses parent selector", ->
    {tokens} = grammar.tokenizeLine('& .foo {}')
    expect(tokens[0]).toEqual value: "&", scopes: ['source.css.less', 'entity.other.attribute-name.parent-selector.css', 'punctuation.definition.entity.css']
    expect(tokens[1]).toEqual value: " ", scopes: ['source.css.less']
    expect(tokens[2]).toEqual value: ".", scopes: ['source.css.less', 'entity.other.attribute-name.class.css', 'punctuation.definition.entity.css']
    expect(tokens[3]).toEqual value: "foo", scopes: ['source.css.less', 'entity.other.attribute-name.class.css']
    expect(tokens[4]).toEqual value: " ", scopes: ['source.css.less']
    expect(tokens[5]).toEqual value: "{", scopes: ['source.css.less', 'meta.property-list.css', 'punctuation.section.property-list.begin.bracket.curly.css']
    expect(tokens[6]).toEqual value: "}", scopes: ['source.css.less', 'meta.property-list.css', 'punctuation.section.property-list.end.bracket.curly.css']

    {tokens} = grammar.tokenizeLine('&:hover {}')
    expect(tokens[0]).toEqual value: "&", scopes: ['source.css.less', 'entity.other.attribute-name.parent-selector.css', 'punctuation.definition.entity.css']
    expect(tokens[1]).toEqual value: ":", scopes: ['source.css.less', 'entity.other.attribute-name.pseudo-class.css', 'punctuation.definition.entity.css']
    expect(tokens[2]).toEqual value: "hover", scopes: ['source.css.less', 'entity.other.attribute-name.pseudo-class.css']
    expect(tokens[3]).toEqual value: " ", scopes: ['source.css.less']
    expect(tokens[4]).toEqual value: "{", scopes: ['source.css.less', 'meta.property-list.css', 'punctuation.section.property-list.begin.bracket.curly.css']
    expect(tokens[5]).toEqual value: "}", scopes: ['source.css.less', 'meta.property-list.css', 'punctuation.section.property-list.end.bracket.curly.css']

  it "parses pseudo element", ->
    {tokens} = grammar.tokenizeLine('.foo::after {}')
    expect(tokens[0]).toEqual value: ".", scopes: ['source.css.less', 'entity.other.attribute-name.class.css', 'punctuation.definition.entity.css']
    expect(tokens[1]).toEqual value: "foo", scopes: ['source.css.less', 'entity.other.attribute-name.class.css']
    expect(tokens[2]).toEqual value: "::", scopes: ['source.css.less', 'entity.other.attribute-name.pseudo-element.css', 'punctuation.definition.entity.css']
    expect(tokens[3]).toEqual value: "after", scopes: ['source.css.less', 'entity.other.attribute-name.pseudo-element.css']
    expect(tokens[4]).toEqual value: " ", scopes: ['source.css.less']
    expect(tokens[5]).toEqual value: "{", scopes: ['source.css.less', 'meta.property-list.css', 'punctuation.section.property-list.begin.bracket.curly.css']
    expect(tokens[6]).toEqual value: "}", scopes: ['source.css.less', 'meta.property-list.css', 'punctuation.section.property-list.end.bracket.curly.css']

  it "parses id selectors", ->
    {tokens} = grammar.tokenizeLine("#abc {}")
    expect(tokens[0]).toEqual value: "#", scopes: ['source.css.less', 'meta.selector.css', 'entity.other.attribute-name.id', 'punctuation.definition.entity.css']
    expect(tokens[1]).toEqual value: "abc", scopes: ['source.css.less', 'meta.selector.css', 'entity.other.attribute-name.id']

    {tokens} = grammar.tokenizeLine("#abc-123 {}")
    expect(tokens[0]).toEqual value: "#", scopes: ['source.css.less', 'meta.selector.css', 'entity.other.attribute-name.id', 'punctuation.definition.entity.css']
    expect(tokens[1]).toEqual value: "abc-123", scopes: ['source.css.less', 'meta.selector.css', 'entity.other.attribute-name.id']

  it "parses custom selectors", ->
    {tokens} = grammar.tokenizeLine("abc-123-xyz {}")
    expect(tokens[0]).toEqual value: "abc-123-xyz", scopes: ['source.css.less', 'entity.name.tag.custom.css']

  it "parses pseudo classes", ->
    {tokens} = grammar.tokenizeLine(".foo:hover { span:last-of-type { font-weight: bold; } }")
    expect(tokens[0]).toEqual value: ".", scopes: ['source.css.less', 'entity.other.attribute-name.class.css', 'punctuation.definition.entity.css']
    expect(tokens[1]).toEqual value: "foo", scopes: ['source.css.less', 'entity.other.attribute-name.class.css']
    expect(tokens[2]).toEqual value: ":", scopes: ['source.css.less', 'entity.other.attribute-name.pseudo-class.css', 'punctuation.definition.entity.css']
    expect(tokens[3]).toEqual value: "hover", scopes: ['source.css.less', 'entity.other.attribute-name.pseudo-class.css']
    expect(tokens[4]).toEqual value: " ", scopes: ['source.css.less']
    expect(tokens[5]).toEqual value: "{", scopes: ['source.css.less', 'meta.property-list.css', 'punctuation.section.property-list.begin.bracket.curly.css']
    expect(tokens[6]).toEqual value: " ", scopes: ['source.css.less', 'meta.property-list.css']
    expect(tokens[7]).toEqual value: "span", scopes: ['source.css.less', 'meta.property-list.css', 'entity.name.tag.css']
    expect(tokens[8]).toEqual value: ":", scopes: ['source.css.less', 'meta.property-list.css', 'entity.other.attribute-name.pseudo-class.css', 'punctuation.definition.entity.css']
    expect(tokens[9]).toEqual value: "last-of-type", scopes: ['source.css.less', 'meta.property-list.css', 'entity.other.attribute-name.pseudo-class.css']
    expect(tokens[10]).toEqual value: " ", scopes: ['source.css.less', 'meta.property-list.css']
    expect(tokens[11]).toEqual value: "{", scopes: ['source.css.less', 'meta.property-list.css', 'meta.property-list.css', 'punctuation.section.property-list.begin.bracket.curly.css']
    expect(tokens[12]).toEqual value: " ", scopes: ['source.css.less', 'meta.property-list.css', 'meta.property-list.css']
    expect(tokens[13]).toEqual value: "font-weight", scopes: ['source.css.less', 'meta.property-list.css', 'meta.property-list.css', 'support.type.property-name.css']
    expect(tokens[14]).toEqual value: ":", scopes: ['source.css.less', 'meta.property-list.css', 'meta.property-list.css', 'punctuation.separator.key-value.css']

  it 'parses nested multiple lines with pseudo-classes', ->
    lines = grammar.tokenizeLines '''
      a { p:hover,
      p:active { color: blue; } }
    '''
    expect(lines[0][0]).toEqual value: 'a', scopes: ['source.css.less', 'entity.name.tag.css']
    expect(lines[0][1]).toEqual value: ' ', scopes: ['source.css.less']
    expect(lines[0][2]).toEqual value: '{', scopes: ['source.css.less', 'meta.property-list.css', 'punctuation.section.property-list.begin.bracket.curly.css']
    expect(lines[0][3]).toEqual value: ' ', scopes: ['source.css.less', 'meta.property-list.css']
    expect(lines[0][4]).toEqual value: 'p', scopes: ['source.css.less', 'meta.property-list.css', 'entity.name.tag.css']
    expect(lines[0][5]).toEqual value: ':', scopes: ['source.css.less', 'meta.property-list.css', 'entity.other.attribute-name.pseudo-class.css', 'punctuation.definition.entity.css']
    expect(lines[0][6]).toEqual value: 'hover', scopes: ['source.css.less', 'meta.property-list.css', 'entity.other.attribute-name.pseudo-class.css']
    expect(lines[0][7]).toEqual value: ',', scopes: ['source.css.less', 'meta.property-list.css', 'punctuation.separator.list.comma.css']
    expect(lines[1][0]).toEqual value: 'p', scopes: ['source.css.less', 'meta.property-list.css', 'entity.name.tag.css']
    expect(lines[1][1]).toEqual value: ':', scopes: ['source.css.less', 'meta.property-list.css', 'entity.other.attribute-name.pseudo-class.css', 'punctuation.definition.entity.css']
    expect(lines[1][2]).toEqual value: 'active', scopes: ['source.css.less', 'meta.property-list.css', 'entity.other.attribute-name.pseudo-class.css']
    expect(lines[1][3]).toEqual value: ' ', scopes: ['source.css.less', 'meta.property-list.css']
    expect(lines[1][4]).toEqual value: '{', scopes: ['source.css.less', 'meta.property-list.css', 'meta.property-list.css', 'punctuation.section.property-list.begin.bracket.curly.css']
    expect(lines[1][5]).toEqual value: ' ', scopes: ['source.css.less', 'meta.property-list.css', 'meta.property-list.css']

  it "parses property lists", ->
    {tokens} = grammar.tokenizeLine(".foo { display: table-row; }")
    expect(tokens).toHaveLength 12
    expect(tokens[0]).toEqual value: ".", scopes: ['source.css.less', 'entity.other.attribute-name.class.css', 'punctuation.definition.entity.css']
    expect(tokens[1]).toEqual value: "foo", scopes: ['source.css.less', 'entity.other.attribute-name.class.css']
    expect(tokens[2]).toEqual value: " ", scopes: ['source.css.less']
    expect(tokens[3]).toEqual value: "{", scopes: ['source.css.less', 'meta.property-list.css', 'punctuation.section.property-list.begin.bracket.curly.css']
    expect(tokens[4]).toEqual value: " ", scopes: ['source.css.less', 'meta.property-list.css']
    expect(tokens[5]).toEqual value: "display", scopes: ['source.css.less', 'meta.property-list.css', 'support.type.property-name.css']
    expect(tokens[6]).toEqual value: ":", scopes: ['source.css.less', 'meta.property-list.css', 'punctuation.separator.key-value.css']
    expect(tokens[7]).toEqual value: " ", scopes: ['source.css.less', 'meta.property-list.css']
    expect(tokens[8]).toEqual value: "table-row", scopes: ['source.css.less', 'meta.property-list.css', 'meta.property-value.css', 'support.constant.property-value.css']
    expect(tokens[9]).toEqual value: ";", scopes: ['source.css.less', 'meta.property-list.css', 'punctuation.terminator.rule.css']
    expect(tokens[10]).toEqual value: " ", scopes: ['source.css.less', 'meta.property-list.css']
    expect(tokens[11]).toEqual value: "}", scopes: ['source.css.less', 'meta.property-list.css', 'punctuation.section.property-list.end.bracket.curly.css']

  it 'parses font lists', ->
    {tokens} = grammar.tokenizeLine '.foo { font-family: "Some Font Name", serif; }'
    expect(tokens[5]).toEqual value: 'font-family', scopes: ['source.css.less', 'meta.property-list.css', 'support.type.property-name.css']
    expect(tokens[9]).toEqual value: 'Some Font Name', scopes: ['source.css.less', 'meta.property-list.css', 'meta.property-value.css', 'string.quoted.double.css']
    expect(tokens[13]).toEqual value: 'serif', scopes: ['source.css.less', 'meta.property-list.css', 'meta.property-value.css', 'support.constant.font-name.css']

  it 'parses an incomplete property list', ->
    {tokens} = grammar.tokenizeLine '.foo { border: none}'
    expect(tokens[5]).toEqual value: 'border', scopes: ['source.css.less', 'meta.property-list.css', 'support.type.property-name.css']
    expect(tokens[8]).toEqual value: 'none', scopes: ['source.css.less', 'meta.property-list.css', 'meta.property-value.css', 'support.constant.property-value.css']
    expect(tokens[9]).toEqual value: '}', scopes: ['source.css.less', 'meta.property-list.css', 'punctuation.section.property-list.end.bracket.curly.css']

  it 'parses multiple lines of an incomplete property-list', ->
    lines = grammar.tokenizeLines '''
      very-custom { color: inherit }
      another-one { display: none; }
    '''
    expect(lines[0][0]).toEqual value: 'very-custom', scopes: ['source.css.less', 'entity.name.tag.custom.css']
    expect(lines[0][4]).toEqual value: 'color', scopes: ['source.css.less', 'meta.property-list.css', 'support.type.property-name.css']
    expect(lines[0][7]).toEqual value: 'inherit', scopes: ['source.css.less', 'meta.property-list.css', 'meta.property-value.css', 'support.constant.property-value.css']
    expect(lines[0][9]).toEqual value: '}', scopes: ['source.css.less', 'meta.property-list.css', 'punctuation.section.property-list.end.bracket.curly.css']

    expect(lines[1][0]).toEqual value: 'another-one', scopes: ['source.css.less', 'entity.name.tag.custom.css']
    expect(lines[1][10]).toEqual value: '}', scopes: ['source.css.less', 'meta.property-list.css', 'punctuation.section.property-list.end.bracket.curly.css']

  it "parses variables", ->
    {tokens} = grammar.tokenizeLine(".foo { border: @bar; }")
    expect(tokens[0]).toEqual value: ".", scopes: ['source.css.less', 'entity.other.attribute-name.class.css', 'punctuation.definition.entity.css']
    expect(tokens[1]).toEqual value: "foo", scopes: ['source.css.less', 'entity.other.attribute-name.class.css']
    expect(tokens[2]).toEqual value: " ", scopes: ['source.css.less']
    expect(tokens[3]).toEqual value: "{", scopes: ['source.css.less', 'meta.property-list.css', 'punctuation.section.property-list.begin.bracket.curly.css']
    expect(tokens[4]).toEqual value: " ", scopes: ['source.css.less', 'meta.property-list.css']
    expect(tokens[5]).toEqual value: "border", scopes: ['source.css.less', 'meta.property-list.css', 'support.type.property-name.css']
    expect(tokens[6]).toEqual value: ":", scopes: ['source.css.less', 'meta.property-list.css', 'punctuation.separator.key-value.css']
    expect(tokens[7]).toEqual value: " ", scopes: ['source.css.less', 'meta.property-list.css']
    expect(tokens[8]).toEqual value: "@", scopes: ['source.css.less', 'meta.property-list.css', 'meta.property-value.css', 'variable.other.less', 'punctuation.definition.variable.less']
    expect(tokens[9]).toEqual value: "bar", scopes: ['source.css.less', 'meta.property-list.css', 'meta.property-value.css', 'variable.other.less']
    expect(tokens[10]).toEqual value: ";", scopes: ['source.css.less', 'meta.property-list.css', 'punctuation.terminator.rule.css']
    expect(tokens[11]).toEqual value: " ", scopes: ['source.css.less', 'meta.property-list.css']
    expect(tokens[12]).toEqual value: "}", scopes: ['source.css.less', 'meta.property-list.css', 'punctuation.section.property-list.end.bracket.curly.css']

  it "parses css variables", ->
    {tokens} = grammar.tokenizeLine(".foo { --spacing-unit: 6px; }")
    expect(tokens[0]).toEqual value: ".", scopes: ['source.css.less', 'entity.other.attribute-name.class.css', 'punctuation.definition.entity.css']
    expect(tokens[1]).toEqual value: "foo", scopes: ['source.css.less', 'entity.other.attribute-name.class.css']
    expect(tokens[2]).toEqual value: " ", scopes: ['source.css.less']
    expect(tokens[3]).toEqual value: "{", scopes: ['source.css.less', 'meta.property-list.css', 'punctuation.section.property-list.begin.bracket.curly.css']
    expect(tokens[4]).toEqual value: " ", scopes: ['source.css.less', 'meta.property-list.css']
    expect(tokens[5]).toEqual value: "--", scopes: ['source.css.less', 'meta.property-list.css', 'variable.other.less', 'punctuation.definition.variable.less']
    expect(tokens[6]).toEqual value: "spacing-unit", scopes: ['source.css.less', 'meta.property-list.css', 'variable.other.less']
    expect(tokens[7]).toEqual value: ":", scopes: ['source.css.less', 'meta.property-list.css', 'punctuation.separator.key-value.css']
    expect(tokens[8]).toEqual value: " ", scopes: ['source.css.less', 'meta.property-list.css']
    expect(tokens[9]).toEqual value: "6", scopes: ['source.css.less', 'meta.property-list.css', 'meta.property-value.css', 'constant.numeric.css']
    expect(tokens[10]).toEqual value: "px", scopes: ['source.css.less', 'meta.property-list.css', 'meta.property-value.css', 'constant.numeric.css', 'keyword.other.unit.px.css']
    expect(tokens[11]).toEqual value: ";", scopes: ['source.css.less', 'meta.property-list.css', 'punctuation.terminator.rule.css']
    expect(tokens[12]).toEqual value: " ", scopes: ['source.css.less', 'meta.property-list.css']
    expect(tokens[13]).toEqual value: "}", scopes: ['source.css.less', 'meta.property-list.css', 'punctuation.section.property-list.end.bracket.curly.css']

  it 'parses variable interpolation in selectors', ->
    {tokens} = grammar.tokenizeLine '.@{selector} { color: #0ee; }'
    expect(tokens[0]).toEqual value: '.', scopes: ['source.css.less', 'entity.other.attribute-name.class.css', 'punctuation.definition.entity.css']
    expect(tokens[1]).toEqual value: '@{selector}', scopes: ['source.css.less', 'entity.other.attribute-name.class.css', 'variable.other.interpolation.less']
    expect(tokens[2]).toEqual value: " ", scopes: ['source.css.less']
    expect(tokens[3]).toEqual value: "{", scopes: ['source.css.less', 'meta.property-list.css', 'punctuation.section.property-list.begin.bracket.curly.css']
    expect(tokens[4]).toEqual value: " ", scopes: ['source.css.less', 'meta.property-list.css']

  it 'parses variable interpolation in properties', ->
    {tokens} = grammar.tokenizeLine '.foo { @{property}: #0ee; }'
    expect(tokens[0]).toEqual value: ".", scopes: ['source.css.less', 'entity.other.attribute-name.class.css', 'punctuation.definition.entity.css']
    expect(tokens[1]).toEqual value: "foo", scopes: ['source.css.less', 'entity.other.attribute-name.class.css']
    expect(tokens[2]).toEqual value: " ", scopes: ['source.css.less']
    expect(tokens[3]).toEqual value: "{", scopes: ['source.css.less', 'meta.property-list.css', 'punctuation.section.property-list.begin.bracket.curly.css']
    expect(tokens[4]).toEqual value: " ", scopes: ['source.css.less', 'meta.property-list.css']
    expect(tokens[5]).toEqual value: '@{property}', scopes: ['source.css.less', 'meta.property-list.css', 'variable.other.interpolation.less']
    expect(tokens[6]).toEqual value: ":", scopes: ['source.css.less', 'meta.property-list.css', 'punctuation.separator.key-value.css']
    expect(tokens[7]).toEqual value: " ", scopes: ['source.css.less', 'meta.property-list.css']

  it 'parses variable interpolation in urls', ->
    {tokens} = grammar.tokenizeLine '.foo { background: #F0F0F0 url("@{var}/img.png"); }";'
    expect(tokens[8]).toEqual value: "#F0F0F0", scopes: ['source.css.less', 'meta.property-list.css', 'meta.property-value.css', 'constant.other.rgb-value.css']
    expect(tokens[10]).toEqual value: "url", scopes: ['source.css.less', 'meta.property-list.css', 'meta.property-value.css', 'support.function.any-method.builtin.url.css']
    expect(tokens[11]).toEqual value: "(", scopes: ['source.css.less', 'meta.property-list.css', 'meta.property-value.css', 'support.function.any-method.builtin.url.css', 'meta.brace.round.css']
    expect(tokens[13]).toEqual value: "@{var}", scopes: ['source.css.less', 'meta.property-list.css', 'meta.property-value.css', 'support.function.any-method.builtin.url.css', 'string.quoted.double.css', 'variable.other.interpolation.less']
    expect(tokens[14]).toEqual value: "/img.png", scopes: ['source.css.less', 'meta.property-list.css', 'meta.property-value.css', 'support.function.any-method.builtin.url.css', 'string.quoted.double.css']

  it 'parses variable interpolation in imports', ->
    {tokens} = grammar.tokenizeLine '@import "@{var}/tidal-wave.less";'
    expect(tokens[0]).toEqual value: "@", scopes: ['source.css.less', 'meta.at-rule.import.css', 'keyword.control.at-rule.import.less', 'punctuation.definition.keyword.less']
    expect(tokens[1]).toEqual value: "import", scopes: ['source.css.less', 'meta.at-rule.import.css', 'keyword.control.at-rule.import.less']
    expect(tokens[2]).toEqual value: " ", scopes: ['source.css.less', 'meta.at-rule.import.css']
    expect(tokens[3]).toEqual value: "\"", scopes: ['source.css.less', 'meta.at-rule.import.css', 'string.quoted.double.css', 'punctuation.definition.string.begin.css']
    expect(tokens[4]).toEqual value: "@{var}", scopes: ['source.css.less', 'meta.at-rule.import.css', 'string.quoted.double.css', 'variable.other.interpolation.less']

  it 'parses options in import statements', ->
    {tokens} = grammar.tokenizeLine '@import (optional, reference) "theme";'
    expect(tokens[0]).toEqual value: "@", scopes: ['source.css.less', 'meta.at-rule.import.css', 'keyword.control.at-rule.import.less', 'punctuation.definition.keyword.less']
    expect(tokens[1]).toEqual value: "import", scopes: ['source.css.less', 'meta.at-rule.import.css', 'keyword.control.at-rule.import.less']
    expect(tokens[4]).toEqual value: "optional", scopes: ['source.css.less', 'meta.at-rule.import.css', 'keyword.control.import.option.less']
    expect(tokens[5]).toEqual value: ",", scopes: ['source.css.less', 'meta.at-rule.import.css', 'punctuation.separator.list.comma.css']
    expect(tokens[7]).toEqual value: "reference", scopes: ['source.css.less', 'meta.at-rule.import.css', 'keyword.control.import.option.less']
    expect(tokens[11]).toEqual value: "theme", scopes: ['source.css.less', 'meta.at-rule.import.css', 'string.quoted.double.css']

  it 'parses built-in functions in property values', ->
    {tokens} = grammar.tokenizeLine '.foo { border: 1px solid rgba(0,0,0); }'
    expect(tokens[0]).toEqual value: ".", scopes: ['source.css.less', 'entity.other.attribute-name.class.css', 'punctuation.definition.entity.css']
    expect(tokens[1]).toEqual value: "foo", scopes: ['source.css.less', 'entity.other.attribute-name.class.css']
    expect(tokens[2]).toEqual value: " ", scopes: ['source.css.less']
    expect(tokens[3]).toEqual value: "{", scopes: ['source.css.less', 'meta.property-list.css', 'punctuation.section.property-list.begin.bracket.curly.css']
    expect(tokens[4]).toEqual value: " ", scopes: ['source.css.less', 'meta.property-list.css']
    expect(tokens[5]).toEqual value: "border", scopes: ['source.css.less', 'meta.property-list.css', 'support.type.property-name.css']
    expect(tokens[6]).toEqual value: ":", scopes: ['source.css.less', 'meta.property-list.css', 'punctuation.separator.key-value.css']
    expect(tokens[8]).toEqual value: "1", scopes: ['source.css.less', 'meta.property-list.css', 'meta.property-value.css', 'constant.numeric.css']
    expect(tokens[9]).toEqual value: "px", scopes: ['source.css.less', 'meta.property-list.css', 'meta.property-value.css', 'constant.numeric.css', 'keyword.other.unit.px.css']
    expect(tokens[11]).toEqual value: "solid", scopes: ['source.css.less', 'meta.property-list.css', 'meta.property-value.css', 'support.constant.property-value.css']
    expect(tokens[13]).toEqual value: "rgba", scopes: ['source.css.less', 'meta.property-list.css', 'meta.property-value.css', 'meta.function.color.css', 'support.function.misc.css']
    expect(tokens[14]).toEqual value: "(", scopes: ['source.css.less', 'meta.property-list.css', 'meta.property-value.css', 'meta.function.color.css', 'punctuation.section.function.begin.bracket.round.css']
    expect(tokens[15]).toEqual value: "0", scopes: ['source.css.less', 'meta.property-list.css', 'meta.property-value.css', 'meta.function.color.css', 'constant.numeric.css']
    expect(tokens[16]).toEqual value: ",", scopes: ['source.css.less', 'meta.property-list.css', 'meta.property-value.css', 'meta.function.color.css', 'punctuation.separator.list.comma.css']
    expect(tokens[17]).toEqual value: "0", scopes: ['source.css.less', 'meta.property-list.css', 'meta.property-value.css', 'meta.function.color.css', 'constant.numeric.css']
    expect(tokens[18]).toEqual value: ",", scopes: ['source.css.less', 'meta.property-list.css', 'meta.property-value.css', 'meta.function.color.css', 'punctuation.separator.list.comma.css']
    expect(tokens[21]).toEqual value: ";", scopes: ['source.css.less', 'meta.property-list.css', 'punctuation.terminator.rule.css']

  it 'parses linear-gradient', ->
    {tokens} = grammar.tokenizeLine '.foo { background: linear-gradient(white, black); }'
    expect(tokens[5]).toEqual value: "background", scopes: ['source.css.less', 'meta.property-list.css', 'support.type.property-name.css']
    expect(tokens[6]).toEqual value: ":", scopes: ['source.css.less', 'meta.property-list.css', 'punctuation.separator.key-value.css']
    expect(tokens[7]).toEqual value: " ", scopes: ['source.css.less', 'meta.property-list.css']
    expect(tokens[8]).toEqual value: "linear-gradient", scopes: ['source.css.less', 'meta.property-list.css', 'meta.property-value.css', 'meta.function.gradient.css', 'support.function.gradient.css']
    expect(tokens[9]).toEqual value: "(", scopes: ['source.css.less', 'meta.property-list.css', 'meta.property-value.css', 'meta.function.gradient.css', 'punctuation.section.function.begin.bracket.round.css']

  it 'parses transform functions', ->
    {tokens} = grammar.tokenizeLine '.foo { transform: scaleY(1); }'
    expect(tokens[5]).toEqual value: "transform", scopes: ['source.css.less', 'meta.property-list.css', 'support.type.property-name.css']
    expect(tokens[6]).toEqual value: ":", scopes: ['source.css.less', 'meta.property-list.css', 'punctuation.separator.key-value.css']
    expect(tokens[7]).toEqual value: " ", scopes: ['source.css.less', 'meta.property-list.css']
    expect(tokens[8]).toEqual value: "scaleY", scopes: ['source.css.less', 'meta.property-list.css', 'meta.property-value.css', 'support.function.transform.css']
    expect(tokens[9]).toEqual value: "(", scopes: ['source.css.less', 'meta.property-list.css', 'meta.property-value.css', 'punctuation.section.function.begin.bracket.round.css']

  it 'parses blend modes', ->
    {tokens} = grammar.tokenizeLine '.foo { background-blend-mode: color-dodge; }'
    expect(tokens[5]).toEqual value: "background-blend-mode", scopes: ['source.css.less', 'meta.property-list.css', 'support.type.property-name.css']
    expect(tokens[6]).toEqual value: ":", scopes: ['source.css.less', 'meta.property-list.css', 'punctuation.separator.key-value.css']
    expect(tokens[7]).toEqual value: " ", scopes: ['source.css.less', 'meta.property-list.css']
    expect(tokens[8]).toEqual value: "color-dodge", scopes: ['source.css.less', 'meta.property-list.css', 'meta.property-value.css', 'support.constant.property-value.css']
    expect(tokens[9]).toEqual value: ";", scopes: ['source.css.less', 'meta.property-list.css', 'punctuation.terminator.rule.css']

  it 'parses non-quoted urls', ->
    {tokens} = grammar.tokenizeLine '.foo { background: url(http://%20/2.png) }'
    expect(tokens[8]).toEqual value: "url", scopes: ['source.css.less', 'meta.property-list.css', 'meta.property-value.css', 'support.function.any-method.builtin.url.css']
    expect(tokens[9]).toEqual value: "(", scopes: ['source.css.less', 'meta.property-list.css', 'meta.property-value.css', 'support.function.any-method.builtin.url.css', 'meta.brace.round.css']
    expect(tokens[10]).toEqual value: "http://%20/2.png", scopes: ['source.css.less', 'meta.property-list.css', 'meta.property-value.css', 'support.function.any-method.builtin.url.css', 'string.url.css']

  it 'parses non-quoted relative urls', ->
    {tokens} = grammar.tokenizeLine '.foo { background: url(../path/to/image.png) }'
    expect(tokens[8]).toEqual value: "url", scopes: ['source.css.less', 'meta.property-list.css', 'meta.property-value.css', 'support.function.any-method.builtin.url.css']
    expect(tokens[9]).toEqual value: "(", scopes: ['source.css.less', 'meta.property-list.css', 'meta.property-value.css', 'support.function.any-method.builtin.url.css', 'meta.brace.round.css']
    expect(tokens[10]).toEqual value: "../path/to/image.png", scopes: ['source.css.less', 'meta.property-list.css', 'meta.property-value.css', 'support.function.any-method.builtin.url.css', 'string.url.css']

  it 'parses non-quoted urls followed by a format', ->
    {tokens} = grammar.tokenizeLine '@font-face { src: url(http://example.com/font.woff) format("woff"); }'
    expect(tokens[8]).toEqual value: 'url', scopes: ['source.css.less', 'meta.property-list.css', 'meta.property-value.css', 'support.function.any-method.builtin.url.css']
    expect(tokens[9]).toEqual value: "(", scopes: ['source.css.less', 'meta.property-list.css', 'meta.property-value.css', 'support.function.any-method.builtin.url.css', 'meta.brace.round.css']
    expect(tokens[10]).toEqual value: "http://example.com/font.woff", scopes: ['source.css.less', 'meta.property-list.css', 'meta.property-value.css', 'support.function.any-method.builtin.url.css', 'string.url.css']
    expect(tokens[11]).toEqual value: ")", scopes: ['source.css.less', 'meta.property-list.css', 'meta.property-value.css', 'support.function.any-method.builtin.url.css', 'meta.brace.round.css']
    expect(tokens[13]).toEqual value: "format", scopes: ['source.css.less', 'meta.property-list.css', 'meta.property-value.css', 'support.function.any-method.builtin.less']

  it 'parses the "true" value', ->
    {tokens} = grammar.tokenizeLine '@var: true;'
    expect(tokens[4]).toEqual value: "true", scopes: ['source.css.less', 'constant.language.boolean.less']

  describe 'mixins', ->
    it 'parses mixin guards', ->
      {tokens} = grammar.tokenizeLine '.mixin() when (isnumber(@b)) and (default()), (ispixel(@a)) and not (@a < 0) { }'
      expect(tokens[0]).toEqual value: '.', scopes: ['source.css.less', 'meta.mixin.less', 'meta.definition.mixin.less', 'entity.name.mixin.less', 'punctuation.definition.mixin.less']
      expect(tokens[1]).toEqual value: 'mixin', scopes: ['source.css.less', 'meta.mixin.less', 'meta.definition.mixin.less', 'entity.name.mixin.less']
      expect(tokens[2]).toEqual value: '(', scopes: ['source.css.less', 'meta.mixin.less', 'meta.parameters.less', 'punctuation.definition.parameters.begin.bracket.round.less']
      expect(tokens[3]).toEqual value: ')', scopes: ['source.css.less', 'meta.mixin.less', 'meta.parameters.less', 'punctuation.definition.parameters.end.bracket.round.less']
      expect(tokens[5]).toEqual value: 'when', scopes: ['source.css.less', 'meta.mixin.less', 'meta.guard.less', 'keyword.control.logical.operator.less']
      expect(tokens[6]).toEqual value: ' ', scopes: ['source.css.less', 'meta.mixin.less', 'meta.guard.less']
      expect(tokens[8]).toEqual value: 'isnumber', scopes: ['source.css.less', 'meta.mixin.less', 'meta.guard.less', 'support.function.type-checking.less']
      expect(tokens[10]).toEqual value: '@', scopes: ['source.css.less', 'meta.mixin.less', 'meta.guard.less', 'variable.other.less', 'punctuation.definition.variable.less']
      expect(tokens[11]).toEqual value: 'b', scopes: ['source.css.less', 'meta.mixin.less', 'meta.guard.less', 'variable.other.less']
      expect(tokens[15]).toEqual value: 'and', scopes: ['source.css.less', 'meta.mixin.less', 'meta.guard.less', 'keyword.control.logical.operator.less']
      expect(tokens[22]).toEqual value: ',', scopes: ['source.css.less', 'meta.mixin.less', 'meta.guard.less', 'punctuation.separator.list.comma.css']
      expect(tokens[32]).toEqual value: 'and not', scopes: ['source.css.less', 'meta.mixin.less', 'meta.guard.less', 'keyword.control.logical.operator.less']
      expect(tokens[43]).toEqual value: '{', scopes: ['source.css.less', 'meta.mixin.less', 'meta.property-list.css', 'punctuation.section.property-list.begin.bracket.curly.css']

    it 'parses mixin parameters', ->
      {tokens} = grammar.tokenizeLine '.foo(@a: 4px, @b) {}'
      expect(tokens[0]).toEqual value: '.', scopes: ['source.css.less', 'meta.mixin.less', 'meta.definition.mixin.less', 'entity.name.mixin.less', 'punctuation.definition.mixin.less']
      expect(tokens[1]).toEqual value: 'foo', scopes: ['source.css.less', 'meta.mixin.less', 'meta.definition.mixin.less', 'entity.name.mixin.less']
      expect(tokens[2]).toEqual value: '(', scopes: ['source.css.less', 'meta.mixin.less', 'meta.parameters.less', 'punctuation.definition.parameters.begin.bracket.round.less']
      expect(tokens[3]).toEqual value: '@', scopes: ['source.css.less', 'meta.mixin.less', 'meta.parameters.less', 'variable.parameter.less', 'punctuation.definition.variable.less']
      expect(tokens[4]).toEqual value: 'a', scopes: ['source.css.less', 'meta.mixin.less', 'meta.parameters.less', 'variable.parameter.less']
      expect(tokens[5]).toEqual value: ':', scopes: ['source.css.less', 'meta.mixin.less', 'meta.parameters.less', 'punctuation.separator.key-value.less']
      expect(tokens[7]).toEqual value: '4', scopes: ['source.css.less', 'meta.mixin.less', 'meta.parameters.less', 'constant.numeric.css']
      expect(tokens[8]).toEqual value: 'px', scopes: ['source.css.less', 'meta.mixin.less', 'meta.parameters.less', 'constant.numeric.css', 'keyword.other.unit.px.css']
      expect(tokens[9]).toEqual value: ',', scopes: ['source.css.less', 'meta.mixin.less', 'meta.parameters.less', 'punctuation.separator.parameter.less']
      expect(tokens[11]).toEqual value: '@', scopes: ['source.css.less', 'meta.mixin.less', 'meta.parameters.less', 'variable.parameter.less', 'punctuation.definition.variable.less']
      expect(tokens[12]).toEqual value: 'b', scopes: ['source.css.less', 'meta.mixin.less', 'meta.parameters.less', 'variable.parameter.less']
      expect(tokens[13]).toEqual value: ')', scopes: ['source.css.less', 'meta.mixin.less', 'meta.parameters.less', 'punctuation.definition.parameters.end.bracket.round.less']

    it 'parses mixin parameters with lists and semicolons', ->
      {tokens} = grammar.tokenizeLine '.foo(@a: darken(#fafafa), absolute, calc(100vh - 40px + 5%), red; @b; @c) {}'
      expect(tokens[3]).toEqual value: '@', scopes: ['source.css.less', 'meta.mixin.less', 'meta.parameters.less', 'variable.parameter.less', 'punctuation.definition.variable.less']
      expect(tokens[4]).toEqual value: 'a', scopes: ['source.css.less', 'meta.mixin.less', 'meta.parameters.less', 'variable.parameter.less']
      expect(tokens[5]).toEqual value: ':', scopes: ['source.css.less', 'meta.mixin.less', 'meta.parameters.less', 'punctuation.separator.key-value.less']
      expect(tokens[7]).toEqual value: 'darken', scopes: ['source.css.less', 'meta.mixin.less', 'meta.parameters.less', 'support.function.any-method.builtin.less']
      expect(tokens[9]).toEqual value: '#', scopes: ['source.css.less', 'meta.mixin.less', 'meta.parameters.less', 'constant.other.color.rgb-value.hex.css', 'punctuation.definition.constant.css']
      expect(tokens[10]).toEqual value: 'fafafa', scopes: ['source.css.less', 'meta.mixin.less', 'meta.parameters.less', 'constant.other.color.rgb-value.hex.css']
      expect(tokens[12]).toEqual value: ',', scopes: ['source.css.less', 'meta.mixin.less', 'meta.parameters.less', 'punctuation.separator.list.comma.css']
      expect(tokens[14]).toEqual value: 'absolute', scopes: ['source.css.less', 'meta.mixin.less', 'meta.parameters.less', 'support.constant.property-value.css']
      expect(tokens[15]).toEqual value: ',', scopes: ['source.css.less', 'meta.mixin.less', 'meta.parameters.less', 'punctuation.separator.list.comma.css']
      expect(tokens[17]).toEqual value: 'calc', scopes: ['source.css.less', 'meta.mixin.less', 'meta.parameters.less', 'meta.function.calc.css', 'support.function.calc.css']
      expect(tokens[19]).toEqual value: '100', scopes: ['source.css.less', 'meta.mixin.less', 'meta.parameters.less', 'meta.function.calc.css', 'constant.numeric.css']
      expect(tokens[20]).toEqual value: 'vh', scopes: ['source.css.less', 'meta.mixin.less', 'meta.parameters.less', 'meta.function.calc.css', 'constant.numeric.css', 'keyword.other.unit.vh.css']
      expect(tokens[22]).toEqual value: '-', scopes: ['source.css.less', 'meta.mixin.less', 'meta.parameters.less', 'meta.function.calc.css', 'keyword.operator.arithmetic.css']
      expect(tokens[24]).toEqual value: '40', scopes: ['source.css.less', 'meta.mixin.less', 'meta.parameters.less', 'meta.function.calc.css', 'constant.numeric.css']
      expect(tokens[25]).toEqual value: 'px', scopes: ['source.css.less', 'meta.mixin.less', 'meta.parameters.less', 'meta.function.calc.css', 'constant.numeric.css', 'keyword.other.unit.px.css']
      expect(tokens[27]).toEqual value: '+', scopes: ['source.css.less', 'meta.mixin.less', 'meta.parameters.less', 'meta.function.calc.css', 'keyword.operator.arithmetic.css']
      expect(tokens[29]).toEqual value: '5', scopes: ['source.css.less', 'meta.mixin.less', 'meta.parameters.less', 'meta.function.calc.css', 'constant.numeric.css']
      expect(tokens[30]).toEqual value: '%', scopes: ['source.css.less', 'meta.mixin.less', 'meta.parameters.less', 'meta.function.calc.css', 'constant.numeric.css', 'keyword.other.unit.percentage.css']
      expect(tokens[32]).toEqual value: ',', scopes: ['source.css.less', 'meta.mixin.less', 'meta.parameters.less', 'punctuation.separator.list.comma.css']
      expect(tokens[34]).toEqual value: 'red', scopes: ['source.css.less', 'meta.mixin.less', 'meta.parameters.less', 'support.constant.color.w3c-standard-color-name.css']
      expect(tokens[35]).toEqual value: ';', scopes: ['source.css.less', 'meta.mixin.less', 'meta.parameters.less', 'punctuation.separator.parameter.less']
      expect(tokens[37]).toEqual value: '@', scopes: ['source.css.less', 'meta.mixin.less', 'meta.parameters.less', 'variable.parameter.less', 'punctuation.definition.variable.less']
      expect(tokens[38]).toEqual value: 'b', scopes: ['source.css.less', 'meta.mixin.less', 'meta.parameters.less', 'variable.parameter.less']
      expect(tokens[39]).toEqual value: ';', scopes: ['source.css.less', 'meta.mixin.less', 'meta.parameters.less', 'punctuation.separator.parameter.less']
      expect(tokens[41]).toEqual value: '@', scopes: ['source.css.less', 'meta.mixin.less', 'meta.parameters.less', 'variable.parameter.less', 'punctuation.definition.variable.less']
      expect(tokens[42]).toEqual value: 'c', scopes: ['source.css.less', 'meta.mixin.less', 'meta.parameters.less', 'variable.parameter.less']
      expect(tokens[43]).toEqual value: ')', scopes: ['source.css.less', 'meta.mixin.less', 'meta.parameters.less', 'punctuation.definition.parameters.end.bracket.round.less']
      expect(tokens[44]).toEqual value: ' ', scopes: ['source.css.less', 'meta.mixin.less']

  describe 'strings', ->
    it 'tokenizes single-quote strings', ->
      {tokens} = grammar.tokenizeLine ".a { content: 'hi' }"

      expect(tokens[8]).toEqual value: "'", scopes: ['source.css.less', 'meta.property-list.css', 'meta.property-value.css', 'string.quoted.single.css', 'punctuation.definition.string.begin.css']
      expect(tokens[9]).toEqual value: 'hi', scopes: ['source.css.less', 'meta.property-list.css', 'meta.property-value.css', 'string.quoted.single.css']
      expect(tokens[10]).toEqual value: "'", scopes: ['source.css.less', 'meta.property-list.css', 'meta.property-value.css', 'string.quoted.single.css', 'punctuation.definition.string.end.css']

    it 'tokenizes double-quote strings', ->
      {tokens} = grammar.tokenizeLine '.a { content: "hi" }'

      expect(tokens[8]).toEqual value: '"', scopes: ['source.css.less', 'meta.property-list.css', 'meta.property-value.css', 'string.quoted.double.css', 'punctuation.definition.string.begin.css']
      expect(tokens[9]).toEqual value: 'hi', scopes: ['source.css.less', 'meta.property-list.css', 'meta.property-value.css', 'string.quoted.double.css']
      expect(tokens[10]).toEqual value: '"', scopes: ['source.css.less', 'meta.property-list.css', 'meta.property-value.css', 'string.quoted.double.css', 'punctuation.definition.string.end.css']

    it 'tokenizes escape characters', ->
      {tokens} = grammar.tokenizeLine ".a { content: '\\abcdef' }"

      expect(tokens[9]).toEqual value: '\\abcdef', scopes: ['source.css.less', 'meta.property-list.css', 'meta.property-value.css', 'string.quoted.single.css', 'constant.character.escape.css']

      {tokens} = grammar.tokenizeLine '.a { content: "\\abcdef" }'

      expect(tokens[9]).toEqual value: '\\abcdef', scopes: ['source.css.less', 'meta.property-list.css', 'meta.property-value.css', 'string.quoted.double.css', 'constant.character.escape.css']
