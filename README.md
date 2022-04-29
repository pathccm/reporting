# Path Reporting

![GitHub Workflow Status](https://img.shields.io/github/workflow/status/pathccm/reporting/Ruby?style=flat-square) ![Gem](https://img.shields.io/gem/v/path-reporting?style=flat-square) ![Libraries.io dependency status for latest release](https://img.shields.io/librariesio/release/rubygems/path-reporting?style=flat-square) ![GitHub](https://img.shields.io/github/license/pathccm/reporting?style=flat-square)

The one stop shop for reporting at [Path](https://pathmentalhealth.com)

This gem contains (or will contain) all the various types of reporting we need
to do at Path. From metrics to analytics to performance and beyond, this gem
is meant to enable us to report anything we need as simply as possible.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add path-reporting

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install path-reporting

## Usage

First you will need to initialize and configure the module

```ruby
Path::Reporting.init do |config|
  config.analytics.logger = Rails.logger
end
```

See [our Configuration docs](https://www.rubydoc.info/gems/path-reporting/Path/Reporting/Configuration)
for more information on how to configure this module

### Analytics

After initialing the module, record an analytics event with the following code.

```ruby

PathReporting.analytics.record(
  product_code: Constants::ANALYTICS_PRODUCT_CODE,
  product_area: Constants::ANALYTICS_PRODUCT_AREA_MATCHING,
  name: 'Preferred provider multiple valid matches',
  user: @contact.analytics_friendly_hash,
  user_type: PathReporting::UserType.PATIENT,
  trigger: PathReporting::Trigger.PAGE_VIEW,
  metadata: analytics_metadata,
)
```

Be sure to read our [Analytics Guide (Internal Doc)](https://docs.google.com/document/d/1axnk1EkKCb__sxtvMomrPNup3wsviDOAefQWwXU3Z3U/edit#)

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/pathccm/reporting.
