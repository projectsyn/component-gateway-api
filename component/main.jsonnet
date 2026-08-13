// main template for gateway-api
local kap = import 'lib/kapitan.libjsonnet';
local inv = kap.inventory();
// The hiera parameters for the component
local params = inv.parameters.gateway_api;

// Define outputs below

local gateway_docs =
  local manifests_dir = '%s/manifests/gateway-api' % inv.parameters._base_directory;
  std.flatMap(
    function(file)
      std.parseJson(kap.yaml_load_stream('%s/%s' % [ manifests_dir, file ])),
    kap.dir_files_list(manifests_dir)
  );

local gateway_crds =
  std.filter(function(doc) doc.kind == 'CustomResourceDefinition', gateway_docs);

local gateway_policies =
  std.filter(function(doc) doc.kind != 'CustomResourceDefinition', gateway_docs);

local is_openshift_419_or_higher =
  std.member([ 'openshift4', 'oke' ], inv.parameters.facts.distribution) &&
  std.parseInt(params.openshift_version.Minor) >= 19;

if params.enabled then
  {
    ['10_gateway_api_crds/' + crd.metadata.name]: crd
    for crd in gateway_crds
    if !is_openshift_419_or_higher
  } + {
    ['20_gateway_api_policies/%s_%s' % [ std.asciiLower(doc.kind), doc.metadata.name ]]: doc
    for doc in gateway_policies
    if !is_openshift_419_or_higher
  }
else
  {}
