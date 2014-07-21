require 'normalize/processor'

describe Normalize::Processor do
  # TODO: Rules relevant to the folllowing samples:
  let(:hash_with_hashrockets) do
    # {
    #   :foo => "bar",
    #   :baz => blah,
    # }
    [
      { :kind=>:on_lbrace, :token=>'{' },
      { :kind=>:on_ignored_nl, :token=>"\n" },
      { :kind=>:on_sp, :token=>'  ' },
      { :kind=>:on_symbeg, :token=>':' },
      { :kind=>:on_ident, :token=>'foo' },
      { :kind=>:on_sp, :token=>' ' },
      { :kind=>:on_op, :token=>'=>' },
      { :kind=>:on_sp, :token=>' ' },
      { :kind=>:on_tstring_beg, :token=>'"' },
      { :kind=>:on_tstring_content, :token=>'bar' },
      { :kind=>:on_tstring_end, :token=>'"' },
      { :kind=>:on_comma, :token=>',' },
      { :kind=>:on_ignored_nl, :token=>"\n" },
      { :kind=>:on_sp, :token=>'  ' },
      { :kind=>:on_symbeg, :token=>':' },
      { :kind=>:on_ident, :token=>'baz' },
      { :kind=>:on_sp, :token=>' ' },
      { :kind=>:on_op, :token=>'=>' },
      { :kind=>:on_sp, :token=>' ' },
      { :kind=>:on_ident, :token=>'blah' },
      { :kind=>:on_comma, :token=>',' },
      { :kind=>:on_ignored_nl, :token=>"\n" },
      { :kind=>:on_rbrace, :token=>'}' },
      { :kind=>:on_nl, :token=>"\n" },
    ]
  end
  let(:hash_without_hashrockets) do
    # {
    #   foo: "blah",
    #   bar: "meh",
    # }
    [
      { :kind=>:on_lbrace,           :token=>'{' },
      { :kind=>:on_ignored_nl,       :token=>"\n" },
      { :kind=>:on_sp,               :token=>'  ' },
      { :kind=>:on_label,            :token=>'foo:' },
      { :kind=>:on_sp,               :token=>' ' },
      { :kind=>:on_tstring_beg,      :token=>'"' },
      { :kind=>:on_tstring_content,  :token=>'blah' },
      { :kind=>:on_tstring_end,      :token=>'"' },
      { :kind=>:on_comma,            :token=>',' },
      { :kind=>:on_ignored_nl,       :token=>"\n" },
      { :kind=>:on_sp,               :token=>'  ' },
      { :kind=>:on_label,            :token=>'bar:' },
      { :kind=>:on_sp,               :token=>' ' },
      { :kind=>:on_tstring_beg,      :token=>'"' },
      { :kind=>:on_tstring_content,  :token=>'meh' },
      { :kind=>:on_tstring_end,      :token=>'"' },
      { :kind=>:on_comma,            :token=>',' },
      { :kind=>:on_ignored_nl,       :token=>"\n" },
      { :kind=>:on_rbrace,           :token=>'}' },
      { :kind=>:on_nl,               :token=>"\n" },
    ]
  end
  let(:hash_without_trailing_comma) do
    # {
    #   foo: "blah",
    #   bar: "meh"
    # }
    [
      { :kind=>:on_lbrace,          :token=>'{' },
      { :kind=>:on_ignored_nl,      :token=>"\n" },
      { :kind=>:on_sp,              :token=>'  ' },
      { :kind=>:on_label,           :token=>'foo:' },
      { :kind=>:on_sp,              :token=>' ' },
      { :kind=>:on_tstring_beg,     :token=>'"' },
      { :kind=>:on_tstring_content, :token=>'blah' },
      { :kind=>:on_tstring_end,     :token=>'"' },
      { :kind=>:on_comma,           :token=>',' },
      { :kind=>:on_ignored_nl,      :token=>"\n" },
      { :kind=>:on_sp,              :token=>'  ' },
      { :kind=>:on_label,           :token=>'bar:' },
      { :kind=>:on_sp,              :token=>' ' },
      { :kind=>:on_tstring_beg,     :token=>'"' },
      { :kind=>:on_tstring_content, :token=>'meh' },
      { :kind=>:on_tstring_end,     :token=>'"' },
      { :kind=>:on_nl,              :token=>"\n" },
      { :kind=>:on_rbrace,          :token=>'}' },
      { :kind=>:on_nl,              :token=>"\n" },
    ]
  end
end
