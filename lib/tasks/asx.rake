namespace :exchange do
  namespace :asx do
      desc "update asx companies list"
      task :update_companies => :environment do
          require 'get_companies_list'
          require 'csv'
          require 'open-uri'
#          require 'ostruct'
          $ASX_LIST_URL = APP_CONFIG[:asx_list_url]
          $FILTER_VOLUME = APP_CONFIG[:filter_volume]
          $FILTER_PRICE = APP_CONFIG[:filter_price]
          $EXCHANGE_NAME = APP_CONFIG[:exchange_name]
          get_companies_list($ASX_LIST_URL,$FILTER_VOLUME,$FILTER_PRICE,$EXCHANGE_NAME)
      end
      desc "update asx indices list"
      task :update_indices => :environment do
          require 'load_indices'
          load_indices
      end

      desc "update prices"
      task :update_prices => :environment do
          require 'update_prices'
          $MAX_DAYS = APP_CONFIG[:max_days]
          Update_prices.get_prices($MAX_DAYS)
      end
      desc "plot graphs"
      task :plot_graphs => :environment do
          $SITE_URL = APP_CONFIG[:site_url]
          $IMAGES_DIR = APP_CONFIG[:images_dir]
          $MMA_MONTHS = APP_CONFIG[:mma_months]
          require 'plot_graphs'
          puts "plotting"
          $BATCH_SIZE=100
          $CHUNK=15
          plot_graphs("#{$SITE_URL}/prices?",$IMAGES_DIR,$MMA_MONTHS,$BATCH_SIZE,$CHUNK)
      end
      desc "send PDFs to Google Drive"
      task :send_to_gdrive => :environment do
          $SITE_URL = APP_CONFIG[:site_url]
          require 'send_to_gdrive'
          send_to_gdrive($SITE_URL,'/tmp','/Stock Scanner Reports')
      end
      desc "update prices and generate images"
      task :daily => [:update_companies, :update_prices, :plot_graphs]
  end
end
