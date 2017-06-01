class MainController < ApplicationController

  def index

  end

  def main

  end

  def save_file
    @param = params[:file]
    @name = @param.original_filename
    File.open("#{@name}", 'wb') { |f| f.write(@param.read)}  #load new file
    @text=Text.new
    @file_text=File.readlines("#{@name}")
    @stroka=" "
    @file_text.each do |file_text|
      @stroka = @stroka +  file_text.chomp
      end

    if request.get?
    else
      @text.sentence=@stroka
    end
    Text.transaction do
      if @text.save
        redirect_to :action=>:choice
      end
    end

  end

  def choice
    @verbs=Verb.all
    @text=Text.last
    @chastotnosts=Chastotnost.all

    @chastota_locs=Chastotnost.all
    @verb_stats=Verbstat.all
    @stats=Stat.all
    @verbs=Verb.all


    @loc_stat = 0
    @verb_stat = 0
    @chastota_locs.each do |loc|
      @kol_vo = loc.kol_vo + 1
      Chastotnost.update(loc.id.to_i, { :kol_vo => @kol_vo} )

    end
    @verb_stats.each do |verb|
      @kol_vo = verb.kol_vo + 1
      Verbstat.update(verb.id.to_i, { :kol_vo => @kol_vo } )
    end
    @locs=Chastotnost.all
    @verbsatel_stat=Verbstat.all


    @locs.each do |loc|
      @loc_stat= @loc_stat + loc.kol_vo
    end
    @verbsatel_stat.each do |verb|
      @verb_stat= @verb_stat + verb.kol_vo
    end

    @vsego=@verb_stat + @loc_stat
    @id_stat = 1
    if  Stat.update(@id_stat, {:vsego => @vsego })
      redirect_to :action=> :upload
    end
  end
  
  def upload
    @verbs=Verb.all
    @text=Text.last
    @chastotnosts=Chastotnost.all
    @chastotnost=Chastotnost.new #obuchenie - add in db
    if request.get?
    else
      @chastotnost.id_verb=params[:chastotnost][:id_verb].to_i
      @chastotnost.righttext=params[:chastotnost][:righttext].to_s
      @chastotnost.kol_vo=params[:chastotnost][:kol_vo].to_i

    end

    @predloj = []
    @verbs.each do |verb| # таблица глаголов
    str=@text.sentence.split('.')

    const = /#{verb.present.to_s}/
    predloj=str.grep(const)
    @str=str #массив ячейка - предложение -->
    word=verb.present.to_s
     if predloj.empty?
    else
     @idverb=verb.id.to_i

     predloj.each do |znach|
       @predloj=@predloj + predloj
       @res=@str - @predloj
       @res.each do |sentence|
         @arr_sent=sentence.split(" ")
       end
     end
     end
    end



  end

  def ask
    @motion_verbs=Verb.all
    @arr_sent=params[:arr_sent]
    @satellites = Satellite.all
    @newtext=Sentence.new
    @status=1
    if request.get?
    else
      @newtext.senten=params[:newtext][:line].to_s
      @newtext.obrabot=@status.to_i
      if @newtext.save
        redirect_to action: :teach
      else
      end
    end
  end

  

  def chastota
    @id_verb=params[:id_verb]
    @righttext=params[:righttext]
  end

  def teach
    @motion_verbs=Verb.all
    @arr_sent=params[:arr_sent]
    @satellites = Satellite.all
    @sentence=Sentence.last


    @verb = Verb.new #добавление глагола
    @verb.errors.messages
    if request.get?
    else
      @verb.present=params[:verb][:present].to_s + " " + params[:satellite][:slovo].to_s
      @verb.past_simple=params[:verb][:past_simple].to_s + " " + params[:satellite][:slovo].to_s
      @verb.past_partic=params[:verb][:past_partic].to_s + " " +params[:satellite][:slovo].to_s
      @verb.third_litco=params[:verb][:third_litco].to_s + " " +params[:satellite][:slovo].to_s


        if @verb.save
          redirect_to action: :upload_stat
        else
        end

    end

  end

  def upload_new
    @verbs=Verb.all
    @text=Text.last
    @chastotnosts=Chastotnost.all

    @predloj = []
    @verbs.each do |verb| # таблица глаголов
      str=@text.sentence.split('.')

      const = /#{verb.present.to_s}/
      predloj=str.grep(const)
      @str=str #массив ячейка - предложение -->
      word=verb.present.to_s
      if predloj.empty?
      else
        @idverb=verb.id.to_i
        @obrabot=0

        predloj.each do |znach|
          @predloj=@predloj + predloj
          @res=@str - @predloj
          @res.each do |sentence|
            @arr_sent=sentence

          end
        end
      end
    end

  end


  def upload_stat
    @verbs=Verb.all
    @text=Text.last
    @chastotnosts=Chastotnost.all

    @verb_stats=Verbstat.all
    @stats=Stat.all
    @verb=Verb.last

    @predloj = []
    @verbs.each do |verb| # таблица глаголов
      str=@text.sentence.split('.')

      const = /#{verb.present.to_s}/
      predloj=str.grep(const) #выбор знакомых предложений
      @str=str #массив ячейка - предложение -->
      word=verb.present.to_s
      if predloj.empty?
      else
        @idverb=verb.id.to_i
        @right_text= " "

        predloj.each do |znach|
          new_ar=znach.strip.split(/\s+/)
          rightword=new_ar.delete_if {|x| x < verb.present.to_s } # правая часть от фраз глагола
          @verbmot=verb.present.split(' ')
          @verb_mot=@verbmot[0]
          @satel=@verbmot[1]

          @right_text=rightword.join(' ')
          phrase_right=@phrase.to_s + " " + rightword.join(" ")
          @const_right=/#{phrase_right}/
          @const_verb=/#{@phrase}/

          @predloj=@predloj + predloj
          @res=@str - @predloj
          @res.each do |sentence|
            @arr_sent=sentence.strip.split(/\s+/)
            rightword=new_ar.delete_if {|x| x < verb.present.to_s }



          end
        end
      end
    end
    if @right_text == " "
    else
      @chastotnost=Chastotnost.new
      @chastotnost.id_verb=@verb.id
      @chastotnost.righttext=@right_text.to_s
      @chastotnost.kol_vo=1

      @verb_stat=Verbstat.new
      @verb_stat.verb_satel=@verb_mot
      @verb_stat.satel=@satel
      @verb_stat.kol_vo=1
      if @chastotnost.save
        redirect_to :action => :upload_new
      else
      end
    end
  end



  
  def input

  end
  def input_verbs
    @subject=params[:subject].to_s

  end
  def input_sat
    @subject=params[:subject].to_s
    @verb=params[:verb][:verb].to_s
  end
  def input_verb
  end
  def verb_inp
    @subject=params[:subject].to_s
  end

  def generate

    @verb=params[:verb].to_s
    @satel=params[:satel].to_s
    @verbsatel=@verb +' ' + @satel
    @subject=params[:subject].to_s
    @stat=Stat.all

    @verb_stat=Verbstat.all
    @phrase_verb=Verb.all
    @id_verb = 0
    @phrase_verb.each do |phrase|
      if @verbsatel == phrase.present.to_s or @verbsatel == phrase.past_simple.to_s or @verbsatel == phrase.past_partic.to_s or @verbsatel == phrase.third_litco.to_s
        @id_verb = phrase.id.to_i
      else

      end
    end

    @chastota_loc=Chastotnost.find_by_sql ["SELECT * FROM public.chastotnosts
        WHERE  chastotnosts.id_verb = ? ORDER BY chastotnosts.kol_vo DESC;", @id_verb]

  end

  def generate_reverse
    @verb=params[:verb].to_s
    @satel=params[:satel].to_s
    @verbsatel=params[:verbsatel].to_s
    @subject=params[:subject].to_s
    @stat=Stat.all

    @verb_stat=Verbstat.all
    @phrase_verb=Verb.all
    @id_verb = params[:id_verb].to_i
    @phrase_verb.each do |phrase|
      if @verbsatel == phrase.present.to_s or @verbsatel == phrase.past_simple.to_s or @verbsatel == phrase.past_partic.to_s or @verbsatel == phrase.third_litco.to_s
        @id_verb = phrase.id.to_i
      else

      end
    end

    @chastota_loc=Chastotnost.find_by_sql ["SELECT * FROM public.chastotnosts
        WHERE  chastotnosts.id_verb = ? ORDER BY chastotnosts.kol_vo ASC;", @id_verb]

  end

  def generate_verb
    @verb_hash=params[:verb]
    @subject=params[:subject].to_s
    @stat=Stat.all

    @verb_hash.each do |key, val|
      @verb=val.to_s
    end


    @verb_stat=Verbstat.all
    @phrase_verb=Verb.all
    @chastverb=Verbstat.find_by_sql ["SELECT * FROM public.verbstats WHERE verbstats.verb_satel = ? ORDER BY verbstats.kol_vo DESC;", @verb ]

  end

  def generate_reverse_verb
    @verb_hash=params[:verb_hash]
    @subject=params[:subject].to_s
    @stat=Stat.all
    @verb_hash.each do |key, val|
      @verb=val.to_s
    end



    @verb_stat=Verbstat.all
    @phrase_verb=Verb.all
    @chastverb=Verbstat.find_by_sql ["SELECT * FROM public.verbstats WHERE verbstats.verb_satel = ? ORDER BY verbstats.kol_vo ASC;", @verb ]


  end

  

  private
  def chastota_params
    params.require(:chastotnost).permit(:id_verb, :righttext)
  end


end
