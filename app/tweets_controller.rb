class TweetsController < UITableViewController
  def viewDidLoad
    @tweets = []
    searchBar = UISearchBar.alloc.initWithFrame(CGRectMake(0, 0, self.tableView.frame.size.width, 0))
    searchBar.delegate = self
    searchBar.showsCancelButton = true
    searchBar.sizeToFit
    view.tableHeaderView = searchBar
    view.dataSource = view.delegate = self
    searchBar.text = ''
    searchBarSearchButtonClicked(searchBar)
  end

  def searchBarSearchButtonClicked(searchBar)
    query = searchBar.text.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
    if GoogleStock.is_valid_stock(query)
      url = "http://search.twitter.com/search.json?q=#{query}"
      @tweets.clear
      Dispatch::Queue.concurrent.async do 
        json = nil
        begin
          json = JSONParser.parse_from_url(url) 
        rescue RuntimeError => e
          presentError e.message
        end

        new_tweets = []
        json['results'].each do |dict|
          new_tweets << Tweet.new(dict)
        end

        Dispatch::Queue.main.sync { load_tweets(new_tweets) }
      end

      searchBar.resignFirstResponder
    else
      @tweets.clear
      load_tweets([])
      presentError("This is not a valid stock search. Try entering a google stock-symbol")
    end unless query == "" 
  end

  def searchBarCancelButtonClicked(searchBar)
    searchBar.resignFirstResponder
  end

  def load_tweets(tweets)
    @tweets = tweets
    view.reloadData
  end
 
  def presentError(error)
    @alert_box = UIAlertView.alloc.initWithTitle("Invalid entry",
        message: error,
        delegate: nil,
        cancelButtonTitle: "ok",
        otherButtonTitles:nil)
    @alert_box.show
    $stderr.puts error.description
  end
 
  def tableView(tableView, numberOfRowsInSection:section)
    @tweets.size
  end

  def tableView(tableView, heightForRowAtIndexPath:indexPath)
    TweetCell.heightForTweet(@tweets[indexPath.row], tableView.frame.size.width)
  end

  def tableView(tableView, cellForRowAtIndexPath:indexPath)
    tweet = @tweets[indexPath.row]
    TweetCell.cellForTweet(tweet, inTableView:tableView)
  end
  
  def reloadRowForTweet(tweet)
    row = @tweets.index(tweet)
    if row
      view.reloadRowsAtIndexPaths([NSIndexPath.indexPathForRow(row, inSection:0)], withRowAnimation:false)
    end
  end
end