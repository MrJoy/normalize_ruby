require 'normalize/processor'

describe Normalize::Processor do
  # TODO: Rules relevant to the folllowing samples:
  let(:hash_with_hashrockets) do
    # {
    #   :foo => "bar",
    #   :baz => blah,
    # }
    [
      {:line=>1, :col=>0, :kind=>:on_lbrace, :token=>'{'},
      {:line=>1, :col=>1, :kind=>:on_ignored_nl, :token=>"\n"},
      {:line=>2, :col=>0, :kind=>:on_sp, :token=>'  '},
      {:line=>2, :col=>2, :kind=>:on_symbeg, :token=>':'},
      {:line=>2, :col=>3, :kind=>:on_ident, :token=>'foo'},
      {:line=>2, :col=>6, :kind=>:on_sp, :token=>' '},
      {:line=>2, :col=>7, :kind=>:on_op, :token=>'=>'},
      {:line=>2, :col=>9, :kind=>:on_sp, :token=>' '},
      {:line=>2, :col=>10, :kind=>:on_tstring_beg, :token=>'"'},
      {:line=>2, :col=>11, :kind=>:on_tstring_content, :token=>'bar'},
      {:line=>2, :col=>14, :kind=>:on_tstring_end, :token=>'"'},
      {:line=>2, :col=>15, :kind=>:on_comma, :token=>','},
      {:line=>2, :col=>16, :kind=>:on_ignored_nl, :token=>"\n"},
      {:line=>3, :col=>0, :kind=>:on_sp, :token=>'  '},
      {:line=>3, :col=>2, :kind=>:on_symbeg, :token=>':'},
      {:line=>3, :col=>3, :kind=>:on_ident, :token=>'baz'},
      {:line=>3, :col=>6, :kind=>:on_sp, :token=>' '},
      {:line=>3, :col=>7, :kind=>:on_op, :token=>'=>'},
      {:line=>3, :col=>9, :kind=>:on_sp, :token=>' '},
      {:line=>3, :col=>10, :kind=>:on_ident, :token=>'blah'},
      {:line=>3, :col=>14, :kind=>:on_comma, :token=>','},
      {:line=>3, :col=>15, :kind=>:on_ignored_nl, :token=>"\n"},
      {:line=>4, :col=>0, :kind=>:on_rbrace, :token=>'}'},
      {:line=>4, :col=>1, :kind=>:on_nl, :token=>"\n"},
    ]
  end
  let(:hash_without_hashrockets) do
    # {
    #   foo: "blah",
    #   bar: "meh",
    # }
    [
      {:line=>1, :col=>0, :kind=>:on_lbrace, :token=>'{'},
      {:line=>1, :col=>1, :kind=>:on_ignored_nl, :token=>"\n"},
      {:line=>2, :col=>0, :kind=>:on_sp, :token=>'  '},
      {:line=>2, :col=>2, :kind=>:on_label, :token=>'foo:'},
      {:line=>2, :col=>6, :kind=>:on_sp, :token=>' '},
      {:line=>2, :col=>7, :kind=>:on_tstring_beg, :token=>'"'},
      {:line=>2, :col=>8, :kind=>:on_tstring_content, :token=>'blah'},
      {:line=>2, :col=>12, :kind=>:on_tstring_end, :token=>'"'},
      {:line=>2, :col=>13, :kind=>:on_comma, :token=>','},
      {:line=>2, :col=>14, :kind=>:on_ignored_nl, :token=>"\n"},
      {:line=>3, :col=>0, :kind=>:on_sp, :token=>'  '},
      {:line=>3, :col=>2, :kind=>:on_label, :token=>'bar:'},
      {:line=>3, :col=>6, :kind=>:on_sp, :token=>' '},
      {:line=>3, :col=>7, :kind=>:on_tstring_beg, :token=>'"'},
      {:line=>3, :col=>8, :kind=>:on_tstring_content, :token=>'meh'},
      {:line=>3, :col=>11, :kind=>:on_tstring_end, :token=>'"'},
      {:line=>3, :col=>12, :kind=>:on_comma, :token=>','},
      {:line=>3, :col=>13, :kind=>:on_ignored_nl, :token=>"\n"},
      {:line=>4, :col=>0, :kind=>:on_rbrace, :token=>'}'},
      {:line=>4, :col=>1, :kind=>:on_nl, :token=>"\n"},
    ]
  end
  let(:hash_without_trailing_comma) do
    # {
    #   foo: "blah",
    #   bar: "meh"
    # }
    [
      {:line=>1, :col=>0, :kind=>:on_lbrace, :token=>'{'},
      {:line=>1, :col=>1, :kind=>:on_ignored_nl, :token=>"\n"},
      {:line=>2, :col=>0, :kind=>:on_sp, :token=>'  '},
      {:line=>2, :col=>2, :kind=>:on_label, :token=>'foo:'},
      {:line=>2, :col=>6, :kind=>:on_sp, :token=>' '},
      {:line=>2, :col=>7, :kind=>:on_tstring_beg, :token=>'"'},
      {:line=>2, :col=>8, :kind=>:on_tstring_content, :token=>'blah'},
      {:line=>2, :col=>12, :kind=>:on_tstring_end, :token=>'"'},
      {:line=>2, :col=>13, :kind=>:on_comma, :token=>','},
      {:line=>2, :col=>14, :kind=>:on_ignored_nl, :token=>"\n"},
      {:line=>3, :col=>0, :kind=>:on_sp, :token=>'  '},
      {:line=>3, :col=>2, :kind=>:on_label, :token=>'bar:'},
      {:line=>3, :col=>6, :kind=>:on_sp, :token=>' '},
      {:line=>3, :col=>7, :kind=>:on_tstring_beg, :token=>'"'},
      {:line=>3, :col=>8, :kind=>:on_tstring_content, :token=>'meh'},
      {:line=>3, :col=>11, :kind=>:on_tstring_end, :token=>'"'},
      {:line=>3, :col=>12, :kind=>:on_nl, :token=>"\n"},
      {:line=>4, :col=>0, :kind=>:on_rbrace, :token=>'}'},
      {:line=>4, :col=>1, :kind=>:on_nl, :token=>"\n"},
    ]
  end
end
