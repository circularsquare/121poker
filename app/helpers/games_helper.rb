module GamesHelper
  def get_player(user, game)

    return game.players.where(:user => user, :ai => "")[0]
  end
  def get_players_cards(player, game)
    return game.cards.where(:location.to_s => player.location.to_s)
  end
  def get_table_cards(game)
    return game.cards.where(:location.to_s => 0)
  end
  def get_random_card(game)
    return game.cards.where(:location => -1)[rand(game.cards.where(:location => -1).length)]
  end
  def in_game(user, game)
    return get_player(user, game)
  end

end
