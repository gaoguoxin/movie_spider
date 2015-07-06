#require 'micro_spider'
require 'mechanize'
require 'logger'
module MovieSpider
  class Tieba
    # path 贴吧主页地址
    # file 表示从firefox导出的cookie.txt文件的绝对路径
    # limit 表示要抓取的pn值,这个pn指的是每次翻页的时候改变的那个pn值
    # limit 值约大,表示抓取数据的时间距离今天越远
    # 比如说1000,那么只收集最活跃的1000条帖子的链接
    def initialize(path,file,limit=0)
      @path    = path
      @agent   = nil
      @limit   = limit
      @file    = file
      @logger  = Logger.new(STDOUT)
      @results = {}
    end


    def start_crawl
      @agent = get_agent
      page   = @agent.get(@path)
      get_post_info(page)
      focus  = get_focus(page)
      return {focus:focus,results:@results}
    end

    def get_focus(page)
      focus = page.search('.j_post_num')[0].text().scan(/\d+/).join('').to_i
    end

    def get_post_info(page)
      interview = page.search(".interviewZero dt.listTitleCnt span.listThreadTitle a")
      if interview
        interview_link = interview.attr('href')
        get_detail(interview_link) 
        @logger.info '--------------------------------完成一个主题的抓取--------------------------------'
      end

      page.search("#thread_list .j_thread_list .threadlist_title a").each do |link|
        link =  "http://tieba.baidu.com" + link.attr('href')
        get_detail(link)
        @logger.info '--------------------------------完成一个主题的抓取--------------------------------'
      end
      @logger.info '**********************************  完成一页主题的抓取  **********************************'
      next_page = page.link_with(:text => '下一页>')
      if next_page
        link    = next_page.href
        pn      = link.to_s.split('pn=').last.to_i
        if pn   <= @limit
          page  = @agent.get(next_page.href)
          get_post_info(page)
        end
      end      
    end

    def get_detail(link)
      tid     = link.to_s.split('/p/').last
      if tid.include?('?pn=')
        tid   = tid.split('?pn=').first
      end
      begin
        page    = @agent.get(link)
      rescue
        @logger.info  '-------------tieba agent get page error  at function get_detail -------------'
        @logger.info  @logger.info "error:#{$!} at:#{$@}"
        begin
          page    = @agent.get(link)
        rescue
          @logger.info "------------  #{link} 链接 获取page 失败  ------------"
        end
      end

      if page.present?
        page404 = page.search('body.page404')
        unless  page404.present?
          posts  = [] # 盛放每页的post用
          title  = page.search(".core_title_txt").attr('title').value
          reply  = page.search(".pb_footer .l_posts_num:first .l_reply_num .red:first").text
          basic  = {} # 盛放主题帖基本信息
          posts  = [] # 盛放跟帖信息
          page.search(".l_post").each do |post|
            info     = JSON.parse(post.attr('data-field'))
            cont     = post.search(".d_post_content_main .d_post_content").text.strip!
            date     = info['content']['date']
  
            if info['content']['post_no'] == 1
              #主题帖
              basic[:author]        = {}
              basic[:title]         = title
              basic[:content]       = cont
              basic[:date]          = date
              basic[:reply]         = reply
              basic[:author][:name] = info["author"]["user_name"]
              basic[:author][:sex]  = info['author']['user_sex'] == 2 ? '女' : '男'
              basic[:author][:level_id]   =  info["author"]["level_id"]
              basic[:author][:level_name] =  info["author"]["level_name"]
            else
              #回复主题帖
              reply_info = {}
              reply_info[:author]      = info["author"]["user_name"] # 回复的作者
              reply_info[:content]     = cont #回复的内容
              reply_info[:comment_num] = info['content']['comment_num'] # 该回复的评论数
              reply_info[:date]        = date #回复的时间
  
              # 回复贴的评论
              if reply_info[:comment_num].to_i > 0 
                pid      = info['content']['post_id']
                pg,rem   = reply_info[:comment_num].to_i.divmod(10)
  
                if rem > 0 
                  pg = pg + 1
                else
                  pg = pg
                end
  
                cmts = []
                1.upto(pg) do |pn|
                  res  = get_cmts(tid,pid,pn)
                  cmts << res  if res.length > 0 
                end
                cmts.flatten!
                reply_info[:comments] = cmts
              end
              posts << reply_info
            end
          end
  
          unless @results["#{tid}"].present?
            @results["#{tid}"]         = {}
            @results["#{tid}"][:basic] =  basic
            @results["#{tid}"][:posts] = []
          end
          @results["#{tid}"][:posts]   << posts
  
          @results["#{tid}"][:posts].flatten!
        end
        next_page = page.link_with(:text => '下一页')
        if next_page
          get_detail(next_page.href)
        end 
      end
    end

    def get_cmts(tid,pid,pn)
      url     = "http://tieba.baidu.com/p/comment?tid=#{tid}&pid=#{pid}&pn=#{pn}&t=#{Time.now.to_i}"
      begin
        page    = @agent.get(url)
      rescue
        @logger.info  '-------------tieba agent get page error at  function get_cmts-------------'
        @logger.info  @logger.info "error:#{$!} at:#{$@}"
        begin
          page    = @agent.get(url)  
        rescue
          @logger.info "------------  #{url} 获取page失败  ------------"
        end
        
      end

      
      cnt_arr = []
      if page.present?
        page.search(".lzl_single_post .lzl_cnt").each do |cnt|
          cnt_hash = {}
          cnt_hash[:author]  = cnt.search("a.j_user_card").text
          cnt_hash[:content] = cnt.search(".lzl_content_main").text.strip!
          cnt_hash[:date]    = cnt.search(".lzl_time").text
          cnt_arr << cnt_hash
        end 
      end
      return cnt_arr
    end

    def get_agent
      agent = Mechanize.new do |a| 
        a.follow_meta_refresh = true
        a.keep_alive = false
        a.ignore_bad_chunking = true
        a.user_agent_alias = 'Mac Safari'
        a.gzip_enabled = false
      end


      if File.exist?(@file)
        mtime = File.mtime(@file)
        ntime = Time.now
        dur   = ntime - mtime

        if dur >= 3600 * 24 * 7
          @logger.info '---------cookie 文件超过七天,请重新生成cookie文件 --------'  
          return false
        end
      else
        @logger.info '---------cookie 文件不存在 --------'
        return false
      end
      agent.cookie_jar.load_cookiestxt(@file)
      agent.user_agent_alias = 'Mac Safari'
      return agent  
    end
  end
end

# tieba = MovieSpider::Tieba.new('http://tieba.baidu.com/f?kw=%E6%88%91%E4%BB%AC15%E4%B8%AA&ie=utf-8','/Users/x/workspace/projects/ruby_projects/Crawler/cookies.txt',50)
# res = tieba.start_crawl

