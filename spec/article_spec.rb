require File.join(File.dirname(__FILE__), 'spec_helper.rb')

describe "Article.path=" do
  it "sets the Article.path" do
    Article.path = (new_article_path = "/some/article/path")
    Article.path == new_article_path
  end
end

describe "Article.path" do
  describe "given an article id" do
    it "returns the Article.path/id.haml" do
      Article.path = "/some/path"
      Article.path("id").should == "/some/path/id.haml"
    end
  end
end

describe "Article.files" do
  before do
    create_article_file(@slug = "an-article-slug")
  end
  it "returns the article filenames from Article.path" do
    all_articles = Article.files
    all_articles.length.should == 1
    all_articles[0].should == File.expand_path(Article.path(@slug))
  end
end

describe "Article.all" do
  it "returns Article's for each Article.files" do
    Article.should_receive(:files).and_return([:article_file])
    File.should_receive(:read).with(:article_file).and_return(:file_read_article_file)
    Article.should_receive(:new).with(:article_file, :file_read_article_file).and_return(:new_article)
    Article.all.should == [:new_article]
  end
end

describe "Article[]" do
  it "returns the article if it exists" do
    article_with_path(filename = "an-article")
    Article["an-article"].should_not be_nil
  end
  it "returns nil if the article doesnt exist" do
    Article["an-article"].should == false
  end
end

describe "Article.new" do
  it "sets the path" do
    article_with_path(path = "/some/path/some-article.haml").path.should == path
  end
  it "sets the template to the contents" do
    article_with_contents("some template content").template == "some template content"
  end
end

describe "Article.parse_date" do
  it "returns nil if arg is nil" do
    Article.parse_date(nil).should be_nil
  end
  it "returns the date" do
    Article.parse_date("2008-12-25").should == ThirdBase::Date.new(2008,12,25)
  end
  it "returns nil if given an invalid date" do
    Article.parse_date("12-25-2008").should be_nil
  end
end

describe "Article#title" do
  it "calls template_variable with 'title'" do
    article = article()
    article.should_receive(:template_variable).with("title").and_return(:article_template_variable_title)
    article.title().should == :article_template_variable_title
  end
end

describe "Article#published" do
  it "calls Article#parse_time with Article#template_variable" do
    article = article_with_published(Time.now)
    article.should_receive(:template_variable).with("published").and_return(:article_template_variable)
    Article.should_receive(:parse_date).with(:article_template_variable).and_return(:article_parse_date)
    article.published().should == :article_parse_date
  end
  it "only calls Article#template_variable once when called multiple times" do
    article = article_with_published(Time.now)
    article.should_receive(:template_variable).and_return(:article_template_variable)
    Article.should_receive(:parse_date).with(:article_template_variable).and_return(:non_nil_article_parse_date)
    article.published()
    article.published()
  end
end

describe "Article#updated" do
  it "calls Article#template_variable" do
    article = article_with_published(Time.now)
    article.should_receive(:template_variable).with("updated").and_return(:article_template_variable)
    Article.should_receive(:parse_date).with(:article_template_variable).and_return(:article_parse_date)
    article.updated().should == :article_parse_date
  end
  it "only calls Article#template_variable once when called multiple times" do
    article = article_with_published(Time.now)
    article.should_receive(:template_variable).with("updated").and_return(:article_template_variable)
    Article.should_receive(:parse_date).with(:article_template_variable).and_return(:article_parse_date)
    article.updated()
    article.updated()
  end
end

describe "Article#last_modified" do
  it "returns published if updated doesn't exist" do
    article = article()
    article.should_receive(:updated).and_return(nil)
    article.should_receive(:published).and_return(:article_published)
    article.last_modified.should == :article_published
  end
  it "returns updated if published exists" do
    article = article()
    article.should_receive(:updated).and_return(:article_updated)
    article.last_modified.should == :article_updated
  end
end

describe "Article#slug" do
  it "returns the article filename w/o extension" do
    article_with_path("/some/path/some-article.haml").slug.should == "some-article"
  end
end

describe "Article#slug" do
  it "returns the article filename w/o extension" do
    article_with_path("/some/path/some-article.haml").slug.should == "some-article"
  end
end

describe "Article#dom_id" do
  it "returns the slug" do
    article = article_with_path("/some/path/some-article.haml")
    article.dom_id.should == article.slug
  end
end

describe "Article.template_variable" do
  it "matches standard \"-# name: value\" format" do
    Article.template_variable("-# variable_name: Variable Value", "variable_name").should == "Variable Value"
  end
  it "ignores whitespace before the dash" do
    Article.template_variable("\t-# variable_name: Variable Value", "variable_name").should == "Variable Value"
  end
  it "ignores whitespace after the dash" do
    Article.template_variable("-\t# variable_name: Variable Value", "variable_name").should == "Variable Value"
  end
  it "matches spaces around the equals" do
    Article.template_variable("-# variable_name:\t Variable Value", "variable_name").should == "Variable Value"
    Article.template_variable("-# variable_name: \tVariable Value", "variable_name").should == "Variable Value"
  end
end

describe "Article#template_variable" do
  it "calls Article.template_variable with the name and template contents" do
    Article.should_receive(:template_variable).with("the contents", :name).and_return(:article_template_variable)
    article_with_contents("the contents").template_variable(:name).should == :article_template_variable
  end
end

describe "Article#<=>" do
  before do
    @older, @later = Date.new(2000,1,1), Date.new(2000,1,2)
  end
  it "returns -1 if this article is more recently published" do
    article_with_published(@later).<=>(article_with_published(@older)).should == -1
  end
  it "returns 0 if the other article has the same published" do
    article_with_published(@older).<=>(article_with_published(@older)).should == 0
  end
  it "returns 1 if the other article is more recently published" do
    article_with_published(@older).<=>(article_with_published(@later)).should == 1
  end
end

describe "Article#path_without_extension" do
  it "returns the path w/o the file extension" do
    article_with_path("/some/path.haml").path_without_extension.should == "/some/path"
  end
end