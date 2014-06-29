require 'normalize/filters/string_filters'
describe Normalize::Filters::StringFilters do
  let(:double_quoted_string) do
    #
    # "foo"
    #
    [
      {:line=>1, :col=>0, :kind=>:on_tstring_beg, :token=>"\""},
      {:line=>1, :col=>0, :kind=>:on_tstring_content, :token=>"foo"},
      {:line=>1, :col=>0, :kind=>:on_tstring_end, :token=>"\""},
      {:line=>1, :col=>0, :kind=>:on_nl, :token=>"\n"},
    ]
  end

  let(:double_quoted_string_empty) do
    #
    # ""
    #
    [
      {:line=>1, :col=>0, :kind=>:on_tstring_beg, :token=>"\""},
      {:line=>1, :col=>0, :kind=>:on_tstring_end, :token=>"\""},
      {:line=>1, :col=>0, :kind=>:on_nl, :token=>"\n"},
    ]
  end

  let(:double_quoted_string_escaped_contents) do
    #
    # "foo \"bar\" baz"
    #
    [
      {:line=>1, :col=>0, :kind=>:on_tstring_beg, :token=>"\""},
      {:line=>1, :col=>0, :kind=>:on_tstring_content, :token=>"foo \\\"bar\\\" baz"},
      {:line=>1, :col=>0, :kind=>:on_tstring_end, :token=>"\""},
      {:line=>1, :col=>0, :kind=>:on_nl, :token=>"\n"},
    ]
  end

  let(:double_quoted_string_single_quote_in_contents) do
    #
    # "foo's bar"
    #
    [
      {:line=>1, :col=>0, :kind=>:on_tstring_beg, :token=>"\""},
      {:line=>1, :col=>0, :kind=>:on_tstring_content, :token=>"foo's bar"},
      {:line=>1, :col=>0, :kind=>:on_tstring_end, :token=>"\""},
      {:line=>1, :col=>0, :kind=>:on_nl, :token=>"\n"},
    ]
  end

  let(:double_quoted_string_with_newline) do
    #
    # "foo
    # bar"
    #
    [
      {:line=>1, :col=>0, :kind=>:on_tstring_beg, :token=>"\""},
      {:line=>1, :col=>0, :kind=>:on_tstring_content, :token=>"foo\nbar"},
      {:line=>2, :col=>0, :kind=>:on_tstring_end, :token=>"\""},
      {:line=>2, :col=>0, :kind=>:on_nl, :token=>"\n"},
    ]
  end

  let(:single_quoted_string) do
    #
    # 'foo'
    #
    [
      {:line=>1, :col=>0, :kind=>:on_tstring_beg, :token=>"'"},
      {:line=>1, :col=>0, :kind=>:on_tstring_content, :token=>"foo"},
      {:line=>1, :col=>0, :kind=>:on_tstring_end, :token=>"'"},
      {:line=>1, :col=>0, :kind=>:on_nl, :token=>"\n"},
    ]
  end
  let(:single_quoted_string_double_quote_in_contents) do
    #
    # 'foo "bar" baz'
    #
    [
      {:line=>1, :col=>0, :kind=>:on_tstring_beg, :token=>"'"},
      {:line=>1, :col=>0, :kind=>:on_tstring_content, :token=>"foo \"bar\" baz"},
      {:line=>1, :col=>0, :kind=>:on_tstring_end, :token=>"'"},
      {:line=>1, :col=>0, :kind=>:on_nl, :token=>"\n"},
    ]
  end
  let(:single_quoted_string_empty) do
    #
    # ''
    #
    [
      {:line=>1, :col=>0, :kind=>:on_tstring_beg, :token=>"'"},
      {:line=>1, :col=>0, :kind=>:on_tstring_end, :token=>"'"},
      {:line=>1, :col=>0, :kind=>:on_nl, :token=>"\n"},
    ]
  end

  let(:single_quoted_string_with_single_quote) do
    #
    # 'foo\'s bar'
    #
    [
      {:line=>1, :col=>0, :kind=>:on_tstring_beg, :token=>"'"},
      {:line=>1, :col=>0, :kind=>:on_tstring_content, :token=>"foo\\'s bar"},
      {:line=>1, :col=>0, :kind=>:on_tstring_end, :token=>"'"},
      {:line=>1, :col=>0, :kind=>:on_nl, :token=>"\n"},
    ]
  end

  let(:single_quoted_string_with_ignored_escape) do
    # Note that the \n doesn't become a newline when interpreted by Ruby.
    #
    # 'foo\nbar'
    #
    [
      {:line=>1, :col=>0, :kind=>:on_tstring_beg, :token=>"'"},
      {:line=>1, :col=>0, :kind=>:on_tstring_content, :token=>"foo\\nbar"},
      {:line=>1, :col=>0, :kind=>:on_tstring_end, :token=>"'"},
      {:line=>1, :col=>0, :kind=>:on_nl, :token=>"\n"},
    ]
  end

  let(:single_quoted_string_with_interpolation_markers) do
    # Note that the #{} doesn't get interpolated when interpreted by Ruby.
    #
    # 'foo #{hash and braces} bar'
    #
    [
      {:line=>1, :col=>0, :kind=>:on_tstring_beg, :token=>"'"},
      {:line=>1, :col=>0, :kind=>:on_tstring_content, :token=>"foo \#{hash and braces} bar"},
      {:line=>1, :col=>0, :kind=>:on_tstring_end, :token=>"'"},
      {:line=>1, :col=>0, :kind=>:on_nl, :token=>"\n"},
    ]
  end


  let(:single_quoted_string_with_adjacent_escapes) do
    #
    # 'adjacent escaping \\\n maybe even a \\...'
    #
    [
      {:line=>1, :col=>0, :kind=>:on_tstring_beg, :token=>"'"},
      {:line=>1, :col=>0, :kind=>:on_tstring_content, :token=>"adjacent escaping \\\\\\n maybe even a \\\\..."},
      {:line=>1, :col=>0, :kind=>:on_tstring_end, :token=>"'"},
      {:line=>1, :col=>0, :kind=>:on_nl, :token=>"\n"},
    ]
  end

  let(:single_quoted_string_with_newline) do
    #
    # 'foo
    # bar'
    #
    [
      {:line=>1, :col=>0, :kind=>:on_tstring_beg, :token=>"'"},
      {:line=>1, :col=>0, :kind=>:on_tstring_content, :token=>"foo\nbar"},
      {:line=>2, :col=>0, :kind=>:on_tstring_end, :token=>"'"},
      {:line=>2, :col=>0, :kind=>:on_nl, :token=>"\n"},
    ]
  end


  describe "ALWAYS_DOUBLE_QUOTED_EMPTY" do
  end
end
