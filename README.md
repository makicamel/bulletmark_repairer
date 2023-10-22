# BulletmarkRepairer

BulletmarkRepairer is an auto corrector for N+1 queries detected at runtime on Ruby on Rails application using [Bullet](https://github.com/flyerhzm/bullet) and [Parser](https://github.com/whitequark/parser).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'bulletmark_repairer', group: %w(development test)
```

## Usage

Run rails server or rspec with REPAIR=1 to autocorrect when N+1 queries are caused.

```bash
REPAIR=1 rails server
REPAIR=1 rspec
```

### How BulletmarkRepairer auto corrects

After receiving Bullet's N+1 notification, find the code that the instance variable is assigned and add `includes` to it.  
Currently, only the controller directory is a candidate for auto correct.  
(We plan to implement allow list in the future)  
Also when N+1 occurs in the views, correct the controller.

### Disclaimer

#### BulletmarkRepairer is *NOT* safe

You must check that auto corrects are correct before you commit.  
For example, when the associations to include depends on the request parameters, human intervention is required.

```ruby
def index
  # Required associations depend on the parameters
  @plays = Play.ransack(params[:q])
end
```

#### BulletmarkRepairer is *NOT* complete

You can check `log/bulletmark_repairer.log` for files where N+1 is detected but not auto corrected.  
For example, the following cases are not supported as known cases currently:

```ruby
def index
  # Nested associations require `includes` though child associations are already included
  @plays = Play.includes(:actors)
  # expected correct
  @plays = Play.includes(actors: [:company])
  # actual correct
  @plays = Play.includes(:actors).includes([:company])
end
```

### Configuration

To customize, add `config/initializers/bulletmark_repairer.rb`:

```ruby
BulletmarkRepairer.configure do |config|
  # when you want to output log to Rails.logger
  config.logger = Rails.logger
  # when BulletmarkRepairer malfunctions, skip the file
  config.skip_file_list = %w[app/controllers/plays_controller.rb]
  # when you want to debug bulletmark_repairer's errors
  config.debug = true
end
```

- `logger`: Injectable logger. In default `Logger.new("#{Rails.root}/log/bulletmark_repairer.log")`
- `skip_file_list`: File list to skip to auto correct. In default `[]`
- `debug`: To raise BulletmarkRepairer's error or not. In default `false`

## Contributing

Bug reports and pull requests are welcome on GitHub at <https://github.com/makicamel/bulletmark_repairer>. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/makicamel/bulletmark_repairer/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the BulletmarkRepairer project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/makicamel/bulletmark_repairer/blob/main/CODE_OF_CONDUCT.md).
