class TweetsController < ApplicationController
  def create
    token = cookies.signed[:session_token]
    session = Session.find_by(token: token)

    if session
      user = session.user
      tweet = user.tweets.new(tweet_params)

      if tweet.save
        render json: {
          tweet: {
            message: tweet.message
          }
        }
      else
        render json: {
          success: false
        }
      end
    else
      render json: {
        success: false
      }
    end
  end

  def destroy
    token = cookies.signed[:session_token]
    session = Session.find_by(token: token)

    if session
      user = session.user
      tweet = Tweet.find_by(id: params[:id], user_id: user.id)

      if tweet and tweet.destroy
        render json: {
          success: true
        }
      end
    end
  end

  def index_by_user
    user = User.find_by(username: params[:username])
    tweets = Tweet.find_by(user_id: user.id)

    if tweets
      tweets.each do |tweet|
        render json: {
          tweet: {
            message: tweet.message
          }
        }
      end
    else
      render json: {
        tweet: []
      }
    end
  end

  def search
    tweets = Tweet.fuzzy_search(message: params[:keyword])

    if tweets
      tweets.each do |tweet|
        render json: {
          tweet: {
            message: tweet.message
          }
        }
      end
    else
      render json: {
        tweet: []
      }
  end

  private

    def tweet_params
      params.require(:tweet).permit(:message)
    end
end
