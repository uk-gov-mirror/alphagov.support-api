require 'uri'

require 'content_api/depts_and_policy_content_lookup'
require 'content_api/gds_owned_content_lookup'
require 'content_api/mainstream_info_lookup'
require 'content_api/orgs_content_lookup'
require 'content_api/worldwide_orgs_content_lookup'
require 'content_api/default_org_content_lookup'

class OrganisationLookup
  def initialize(content_api, content_store)
    @lookups = [
      ContentAPI::GDSOwnedContentLookup.new,
      ContentAPI::MainstreamInfoLookup.new(content_api),
      ContentAPI::OrgsContentLookup.new(content_store),
      ContentAPI::WorldwideOrgsContentLookup.new,
      ContentAPI::DeptsAndPolicyContentLookup.new(content_api),
      ContentAPI::DefaultOrgContentLookup.new,
    ]
  end

  def organisations_for(path)
    applicable_lookups = @lookups.select { |lookup| lookup.applies?(path) }
    applicable_lookups.each do |lookup|
      orgs = lookup.organisations_for(path)
      return orgs unless orgs.empty?
    end
    nil
  end

  def content_item_path(path)
    lookup = @lookups.detect { |lookup| lookup.applies?(path) }
    lookup.content_item_path(path)
  end
end
