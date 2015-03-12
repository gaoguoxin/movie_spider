require 'micro_spider'
require 'logger'
module MovieSpider
  class Star
    def initialize(word=nil,start=nil,to=nil)
      @word    = word
      @start   = start
      @to      = to
      @sources = get_all_sources
      @logger  = Logger.new(STDOUT)
    end

    def get_all_sources
      hash = Hash.new(0)
      hash['xinhuanet.com'] = "新华网"
      hash['peopledaily.com.cn'] = "人民网"
      hash['chinanews.com.cn'] = "中新网"
      hash['news.sina.com.cn'] = "新浪"
      hash['news.sohu.com'] = "搜狐"
      hash['news.163.com'] = "网易"
      hash['cn.news.yahoo.com'] = "雅虎"
      hash['news.tom.com'] = "Tom"
      hash['news.china.com'] = "中华网"
      hash['news.21cn.com'] = "21CN"
      hash['huanqiu.com'] = "环球网"
      hash['rednet.com.cn'] = "红网"
      hash['cnhan.com'] = "汉网"
      hash['cctv.com'] = "CCTV"
      hash['news.enorth.com.cn'] = "北方网"
      hash['northeast.com.cn'] = "东北网"
      hash['southcn.com'] = "南方网"
      hash['chinawestnews.net'] = "西部网"
      hash['dzwww.com'] = "大众网"
      hash['anhuinews.com'] = "中安网"
      hash['china.com.cn'] = "中国网"
      hash['longhoo.net'] = "龙虎网"
      hash['news.beelink.com.cn'] = "百灵网"
      hash['runsky.com'] = "天健网"
      hash['tianshannet.com.cn'] = "天山网"
      hash['jcrb.com.cn'] = "正义网"
      hash['eastday.com'] = "东方网"
      hash['cjmedia.com.cn'] = "长江网"
      hash['cqnews.net'] = "华龙网"
      hash['ben.com.cn'] = "京报网"
      hash['phoenixtv.com'] = "凤凰网"
      hash['newgx.com.cn'] = "新桂网"
      hash['huash.com'] = "华商网"
      hash['sportscn.com'] = "华体网"
      hash['jxnews.cc'] = "大江网"
      hash['dahuawang.com'] = "大华网"
      hash['dayoo.com'] = "大洋网"
      hash['gmw.com.cn'] = "光明网"
      hash['ycwb.com'] = "金羊网"
      hash['lswb.com.cn'] = "北国网"
      hash['hnby.com.cn'] = "河南报业网"
      hash['hsm.com.cn'] = "中国侨网"
      hash['tibetinfor.com.cn'] = "西藏信息中心"
      hash['xjbs.com.cn'] = "新疆新闻在线"
      hash['beinet.net.cn'] = "北京经济信息网"
      hash['cei.gov.cn'] = "中国经济信息网"
      hash['online.sh.cn'] = "上海热线"
      hash['xaonline.com'] = "古城热线"
      hash['sd.cninfo.net'] = "齐鲁热线"
      hash['online.tj.cn'] = "天津热线"
      hash['news.szonline.net'] = "深圳热线"
      hash['news.tfol.com'] = "天府热线"
      hash['hebei.com.cn'] = "长城在线"
      hash['ahrb.com.cn'] = "安徽在线"
      hash['zjonline.com.cn'] = "浙江在线"
      hash['gog.com.cn'] = "金黔在线"
      hash['sconline.com.cn'] = "四川在线"
      hash['westking.cn'] = "西部在线"
      hash['cyd.com.cn'] = "中青在线"
      hash['gansudaily.com.cn'] = "每日甘肃"
      hash['shanxi.gov.cn'] = "中国山西"
      hash['pudong.gov.cn'] = "上海浦东"
      hash['jsinfo.net'] = "江苏音符"
      hash['yztoday.com'] = "今日扬州"
      hash['huaxia.com'] = "华夏经纬"
      hash['online.cri.com.cn'] = "国际在线"
      hash['qianlong.com'] = "千龙新闻网"
      hash['hnrb.hinews.cn'] = "海南新闻网"
      hash['news.sdinfo.net'] = "齐鲁新闻网"
      hash['sxrb.com'] = "山西新闻网"
      hash['gxnews.com.cn'] = "桂龙新闻网"
      hash['sznews.com'] = "深圳新闻网"
      hash['qhnews.com'] = "青海新闻网"
      hash['newssc.org'] = "四川新闻网"
      hash['nxnews.net'] = "宁夏新闻网"
      hash['tynews.com.cn'] = "太原新闻网"
      hash['nen.com.cn'] = "东北新闻网"
      hash['zzwb.com.cn'] = "中原新闻网"
      hash['qingdaonews.com'] = "青岛新闻网"
      hash['cnnb.com.cn'] = "中国宁波网"
      hash['jschina.com.cn'] = "中国江苏网"
      hash['jxcn.cn'] = "中国江西网"
      hash['chinajilin.com.cn'] = "中国吉林网"
      hash['gz.cninfo.net'] = "贵州信息港"
      hash['shangdu.com'] = "商都信息港"
      return hash      
    end


    # 高级搜索页面设置搜索条件并开始抓取
    def get_special_site_news_list
      results = []
      sites = %w(xinhuanet.com peopledaily.com.cn chinanews.com.cn news.sina.com.cn news.sohu.com news.163.com cn.news.yahoo.com news.tom.com news.china.com news.21cn.com huanqiu.com rednet.com.cn cnhan.com cctv.com news.enorth.com.cn northeast.com.cn southcn.com chinawestnews.net dzcom anhuinews.com china.com.cn longhoo.net news.beelink.com.cn runsky.com tianshannet.com.cn jcrb.com.cn eastday.com cjmedia.com.cn cqnews.net ben.com.cn phoenixtv.com newgx.com.cn huash.com sportscn.com jxnews.cc dahuawang.com dayoo.com gmw.com.cn ycwb.com lswb.com.cn hnby.com.cn hsm.com.cn tibetinfor.com.cn xjbs.com.cn beinet.net.cn cei.gov.cn online.sh.cn xaonline.com sd.cninfo.net online.tj.cn news.szonline.net news.tfol.com hebei.com.cn ahrb.com.cn zjonline.com.cn gog.com.cn sconline.com.cn westking.cn cyd.com.cn gansudaily.com.cn shanxi.gov.cn pudong.gov.cn jsinfo.net yztoday.com huaxia.com online.cri.com.cn qianlong.com hnrb.hinews.cn news.sdinfo.net sxrb.com gxnews.com.cn sznews.com qhnews.com newssc.org nxnews.net tynews.com.cn nen.com.cn zzwb.com.cn qingdaonews.com cnnb.com.cn jschina.com.cn jxcn.cn chinajilin.com.cn gz.cninfo.net shangdu.com)
      sites.each do |site|
        hash = Hash.new(0)
        hash["#{@sources[site]}"] = get_news_list(site)
        results << hash
      end
      return results
    end


    def get_news_list(site)
      uri   = URI("http://news.baidu.com/advanced_news.html")
      agp   = get_agent(uri)
      agent = agp.first
      page  = agp.last     
      
      search_form = page.form_with(:name => "f")
      search_form.field_with(:name => "q1").value = "#{@word}"
      search_form.radiobuttons_with(:name => 's')[1].check
      search_form.field_with(:name => "begin_date").value = "#{@start}"
      search_form.field_with(:name => "end_date").value = "#{@to}"
      search_form.field_with(:name => 'rn').options[3].select
      search_form.field_with(:name => "q6").value = "#{site}"
      search_results = agent.submit search_form
      hash = Hash.new(0)
      hash[:total] = search_results.search('#header_top_bar .nums').text.scan(/\d+/).first.to_i
      hash[:svg]   = get_svg(search_results) 
      @logger.info hash.inspect
      @logger.info('----------------------------------------------------------------------------')
      return hash
    end


    def get_svg(search_results)
      count = search_results.search('#content_left  .result').length
      return count if count == 0
      num   = 0 
      search_results.search('#content_left  .result').each do |li|
        lin = li.search('.c-more_link')
        if lin.present?
          num   += lin.text.scan(/\d+/).first.to_i
        end        
      end
      return num.to_f / count
    end


    def get_agent(uri)
      agent = Mechanize.new
      agent.user_agent_alias = 'Mac Safari'
      page  = agent.get uri
      page.encoding = 'utf-8'
      return [agent,page]
    end
  end
end


#star = MovieSpider::Star.new('穹顶之下','2015-02-28','2015-03-02')
#star = MovieSpider::Star.new('雾霾','2015-02-28','2015-03-02')
#star = MovieSpider::Star.new('柴静','2015-2-28','2015-3-5')
#star.get_special_site_news_list





