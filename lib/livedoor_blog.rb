require "livedoor_blog/version"
require 'mechanize'
require 'logger'
require 'json'
require 'erb'
  
class LivedoorBlog
  def initialize
    @logger = Logger.new(STDERR)
    @logger.level = Logger::INFO

    @a = Mechanize.new
    @a.user_agent_alias = "Linux Firefox"
  end

  def login(livedoor_id, password)
    @livedoor_id = livedoor_id
    @password = password

    get("https://member.livedoor.com/login/?.sv=top")
    submit('loginForm', 'livedoor_id' => @livedoor_id, 'password' => @password)
    @rkey = get_rkey
  end

  def upload_image(image_file, folder = nil)
    @logger.info("uploading #{image_file}")
    folder_id = nil
    if folder
      folder_id = folder_list.detect{|x|
        x["name"] == folder
      }["id"]
    end
    @logger.info("folder_id: #{folder_id}")
    File.open(image_file){|f|
      res = @a.post("http://livedoor.blogcms.jp/livedoor/#{@livedoor_id}/file/image/multi_upload", {:rkey => @rkey, 'file_1' => f, 'folder_1' => folder_id})
      @logger.debug(res.body)
      JSON.parse(res.body)["result"].first["image_url"]
    }
  end

  def submit_entry(title, body)
    click('ブログを書く')
    click('記事を書く')
    submit('ArticleForm', 'body' => body, 'title' => title)
  end

  def create_folder(name)
    page = @a.post("http://livedoor.blogcms.jp/blog/#{@livedoor_id}/file/folder/api/add", {
      :name => name,
      :rkey => @rkey,
    })
    JSON.parse(page.body)
  end

  def folder_list
    page = @a.get("http://livedoor.blogcms.jp/blog/#{@livedoor_id}/file/folder/api/folders_pager")
    h = JSON.parse(page.body)
    h["entries"]
  end

private
 
  def get(url)
    @logger.info("GET #{url}")
    @page = @a.get(url)
  end

  def click(text)
    @page = @page.link_with(:text => text).click
  end

  def submit(name, h)
    form = @page.form_with(:name => name)
    h.each{|name,value|
      field = form.field_with(:name => name)
      field.value = value
    }
    @page = form.submit
  end

  def get_rkey
    page = @a.get("http://livedoor.blogcms.jp/blog/#{@livedoor_id}/file/image/")
    rkey = page.content.slice(/var rkey\s+= '(\w+)'/,1)
    @logger.info("rkey: '#{rkey}'")
    rkey
  end
end
