class GamesController < ApplicationController
  before_action :set_game, only: [:show, :edit, :update, :destroy]


  # GET /games
  # GET /games.json
  def index
    @games = Game.all
  end

  # GET /games/1
  # GET /games/1.json
  # TODO: move game logic
  def show

  end

  # GET /games/new
  def new
    @game = Game.new
  end

  # GET /games/1/edit
  def edit
  end

  # POST /games
  # POST /games.json
  def create
    @game = Game.create(game_params)
    @game.init
    respond_to do |format|
      if @game.save
        format.html { redirect_to @game, notice: 'Game was successfully created.' }
        format.json { render :show, status: :created, location: @game }
      else
        format.html { render :new }
        format.json { render json: @game.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /games/1
  # PATCH/PUT /games/1.json
  def update
    respond_to do |format|
      if @game.update(game_params)
        format.html { redirect_to @game, notice: 'Game was successfully updated.' }
        format.json { render :show, status: :ok, location: @game }
      else
        format.html { render :edit }
        format.json { render json: @game.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /games/1
  # DELETE /games/1.json
  def destroy
    @game.players.each do |p|
      p.destroy
    end

    @game.destroy
    respond_to do |format|
      format.html { redirect_to games_url, notice: 'Game was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def add_ai
    Game.find_by(id: params[:game]).add_ai_player(params[:type], User.find_by(id: params[:user].to_i))
    redirect_back(fallback_location: root_path)
  end
  def add_player
    Game.find_by(id: params[:game]).add_user_player(User.find_by(id: params[:user].to_i))
    redirect_back(fallback_location: root_path)
  end
  def move_card
    Game.find(params[:game]).move_card(Card.find(params[:card]), params[:destination])
    redirect_back(fallback_location: root_path)
  end
  def action
    Game.find_by(id: params[:game]).player_action(params[:type], params[:amount], params[:player])
    p params
    redirect_back(fallback_location: root_path)
  end
  def deal
    Game.find_by(id: params[:game]).deal(params[:round])
    redirect_back(fallback_location: root_path)
  end
  def set_round
    Game.find_by(id: params[:game]).set_round(params[:round])
    redirect_back(fallback_location: root_path)
  end
  def leave_game
    Game.find_by(id: params[:game]).leave_game(params[:player])
    redirect_back(fallback_location: root_path)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_game
      @game = Game.find(params[:id])
    end
    # Only allow a list of trusted parameters through.
    def game_params
      params.require(:game).permit(:room_name)
    end
end
