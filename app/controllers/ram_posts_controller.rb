class RamPostsController < ApplicationController
  before_action :set_ram_post, only: [:show, :edit, :update, :destroy]

  # GET /ram_posts
  # GET /ram_posts.json
  def index
    @ram_posts = RamPost.all
  end

  # GET /ram_posts/1
  # GET /ram_posts/1.json
  def show
  end

  # GET /ram_posts/new
  def new
    @ram_post = RamPost.new
  end

  # GET /ram_posts/1/edit
  def edit
  end

  # POST /ram_posts
  # POST /ram_posts.json
  def create
    @ram_post = RamPost.new(ram_post_params)

    respond_to do |format|
      if @ram_post.save
        format.html { redirect_to @ram_post, notice: 'Ram post was successfully created.' }
        format.json { render :show, status: :created, location: @ram_post }
      else
        format.html { render :new }
        format.json { render json: @ram_post.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /ram_posts/1
  # PATCH/PUT /ram_posts/1.json
  def update
    respond_to do |format|
      if @ram_post.update(ram_post_params)
        format.html { redirect_to @ram_post, notice: 'Ram post was successfully updated.' }
        format.json { render :show, status: :ok, location: @ram_post }
      else
        format.html { render :edit }
        format.json { render json: @ram_post.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /ram_posts/1
  # DELETE /ram_posts/1.json
  def destroy
    @ram_post.destroy
    respond_to do |format|
      format.html { redirect_to ram_posts_url, notice: 'Ram post was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_ram_post
      @ram_post = RamPost.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def ram_post_params
      params.require(:ram_post).permit(:words)
    end
end
