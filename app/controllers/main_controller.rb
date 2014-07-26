class MainController < ApplicationController

  def test_crap
    #p @client.submissions("starmendotnet.tumblr.com")['posts'][0]['id']
    #render text:@client.submissions("starmendotnet.tumblr.com").to_yaml, content_type: :text
    #return
    #post = @client.submissions("starmendotnet.tumblr.com")['posts'][0]
    #id = post['id']
    #reblog_key = post['reblog_key']
    #@client.edit('starmendotnet.tumblr.com',{id: id, state:'published'})

    #render text:"lol #{id}"
    #render text:@client.edit('starmendotnet.tumblr.com',{id: id, state:'published',post_author:'rofishstestacount'}).to_yaml, content_type: :text
    #text = ''
    #text += @client.posts('starmendotnet.tumblr.com').to_yaml
    #text += @client.edit('starmendotnet.tumblr.com',{id: id, state:'published'}).to_yaml
    #text += @client.reblog('starmendotnet.tumblr.com',{id: id, reblog_key: reblog_key}).to_yaml
    #text += @client.delete('starmendotnet.tumblr.com',id).to_yaml
    #render text:text, content_type: :text
  end

  def queued
    @posts = @client.queue('starmendotnet.tumblr.com')['posts']
  end

  def submissions
    @posts = @client.submissions('starmendotnet.tumblr.com')['posts']
  end

  def requeue
    @post = @client.posts('starmendotnet.tumblr.com',id:params[:id]).try(:[],'posts').try(:first)

    if @post.blank?
      raise ActiveRecord::RecordNotFound #404
    else
      @client.edit('starmendotnet.tumblr.com',{id:params[:id],state:'draft'})
      @client.edit('starmendotnet.tumblr.com',{id:params[:id],state:'queue'})
    end

    redirect_to action: :queued
  end

  def add_to_queue
    @post = @client.posts('starmendotnet.tumblr.com',id:params[:id]).try(:[],'posts').try(:first)

    if @post.blank?
      raise ActiveRecord::RecordNotFound #404
    elsif @post['state'] == 'queue'
      #do nothing
    else
      tags = @post['tags']
      tags << "staff:#{session[:username]}"
      @client.edit('starmendotnet.tumblr.com',{id:params[:id],state:'queue',tags:tags})
    end

    redirect_back
  end

  def edit
    if params[:state] == 'queued'
      @post = @client.posts('starmendotnet.tumblr.com',id:params[:id]).try(:[],'posts').try(:first)
    elsif params[:state] == 'submission'
      @post = @client.posts('starmendotnet.tumblr.com',id:params[:id]).try(:[],'posts').try(:first)
    else
      render text:'unknown', status:422
      return
    end

    # render text:@post.to_yaml, content_type: :text
    # return

    if @post.blank?
      raise ActiveRecord::RecordNotFound #404
    elsif @post['type'] == 'text'
      render action: :edit_text
    elsif @post['type'] == 'photo'
      render action: :edit_photo
    elsif @post['type'] == 'link'
      render action: :edit_link
    elsif @post['type'] == 'audio'
      render action: :edit_audio
    elsif @post['type'] == 'video'
      render action: :edit_video
    else
      render text:"wtf unknown type? #{@post['type']}", status:422
    end

    #render text:@post.to_yaml, content_type: :text
  end

  def update
    #p params[:post].merge(id:params[:id])
    @client.edit('starmendotnet.tumblr.com',params[:post].merge(id:params[:id]))
    redirect_back
  end

  def tagged
    @posts = @client.tagged(params[:tag],before:params[:before])
    ids = @posts.map{|x| x['id'].to_s}
    hashmap = Reblog.where(tumblr_id:ids).map{|x| [x.tumblr_id,x.reblogged_by]}
    @reblogs = Hash[hashmap]
  end

  def reblog_params
    params[:reblog].permit(:id, :reblog_key, :tags)
  end

  def reblog
    # reblog to our queue
    tags = reblog_params[:tags].split(',')
    tags << "staff:#{session[:username]}"
    reblog = @client.reblog('starmendotnet.tumblr.com',id:reblog_params[:id],reblog_key:reblog_params[:reblog_key], tags:tags, state:'queue')

    # create a log
    Reblog.create(tumblr_id:params[:id],reblogged_by:session[:username])

    redirect_to :root
    #render text:@client.reblog('starmendotnet.tumblr.com',id:params[:id],reblog_key:params[:reblog_key], state:'queue').to_yaml, content_type: :text
  end

  def redirect_back
    if params[:state] == 'submission'
      redirect_to action: :submissions
    elsif params[:state] == 'queued'
      redirect_to action: :queued
    else
      redirect_to action: :index
    end
  end

  # def tumblr_callback
  #   if !request.env["omniauth.auth"]['info']['blogs'].detect{|x| x['name']=='starmendotnet'}
  #     render text:'<h1>You do not have access to edit blog starmendotnet</h1>', status: :unauthorized
  #     return
  #   end

  #   #render text:request.env["omniauth.auth"].to_yaml, content_type: :text
  #   session[:oauth_token] = request.env["omniauth.auth"]['credentials']['token']
  #   session[:oauth_secret] = request.env["omniauth.auth"]['credentials']['secret']
  #   session[:last_login] = Time.now

  #   render text:request.env["omniauth.auth"]['credentials'].to_yaml, content_type: :text

  #   #redirect_to action: :index
  # end

  API_KEY = "smn-tumblr-admin.herokuapp.com"
  API_SECRET = ENV['SMN_TUMBLR_FG_SECRET']

  def fangamer_callback
    signature = Base64.encode64(OpenSSL::HMAC.digest('sha1', API_SECRET, params[:multipass]))
    if signature.strip != params[:signature].strip
      render text:'signature error'
      return
    end

    prepended = Base64.decode64(params[:multipass])

    iv = prepended[0..15]
    encrypted = prepended[16..1000000000]

    key = Digest::SHA1.digest(API_KEY + API_SECRET)[0...16]

    cipher = OpenSSL::Cipher::Cipher.new("aes-128-cbc")
    cipher.decrypt # specifies the cipher's mode (encryption vs decryption)
    cipher.key = key
    cipher.iv = iv
    json = cipher.update(encrypted) + cipher.final

    data = JSON.load(json)

    expires = Time.parse data['expires']

    if expires < Time.now
      render text:'Time Expired.'
      return
    end

    session[:username] = data['username']
    session[:last_login] = Time.now

    redirect_to action: :index
  end
end
