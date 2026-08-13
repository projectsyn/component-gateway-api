/**
 * \file Library with public methods provided by component gateway-api.
 */

/**
 * The Gateway API K8s API group
 */
local gateway_group = 'gateway.networking.k8s.io';

/**
 * The Experimental Gateway API K8s API group
 * Only present on clusters which install the experimental channel
 */
local gateway_experimental_group = 'gateway.networking.x-k8s.io';

/**
 * Helper function to create Gateway API GatewayClass resources
 *
 * \arg name used as `metadata.name`
 * \returns a partial `GatewayClass` object
 */
local GatewayClass = function(name='') {
  apiVersion: '%s/v1' % gateway_group,
  kind: 'GatewayClass',
  metadata: {
    name: name,
    annotations: {
      'argocd.argoproj.io/sync-options': 'SkipDryRunOnMissingResource=true',
    },
  },
};

/**
 * Helper function to create Gateway API Gateway resources
 *
 * \arg name used as `metadata.name`
 * \returns a partial `Gateway` object
 */
local Gateway = function(name='') {
  apiVersion: '%s/v1' % gateway_group,
  kind: 'Gateway',
  metadata: {
    name: name,
    annotations: {
      'argocd.argoproj.io/sync-options': 'SkipDryRunOnMissingResource=true',
    },
  },
};

/**
 * Helper function to create Gateway API HTTPRoute resources
 *
 * \arg name used as `metadata.name`
 * \returns a partial `HTTPRoute` object
 */
local HTTPRoute = function(name='') {
  apiVersion: '%s/v1' % gateway_group,
  kind: 'HTTPRoute',
  metadata: {
    name: name,
    annotations: {
      'argocd.argoproj.io/sync-options': 'SkipDryRunOnMissingResource=true',
    },
  },
};

/**
 * Helper function to create Gateway API ReferenceGrant resources
 *
 * \arg name used as `metadata.name`
 * \returns a partial `ReferenceGrant` object
 */
local ReferenceGrant = function(name='') {
  apiVersion: '%s/v1beta1' % gateway_group,
  kind: 'ReferenceGrant',
  metadata: {
    name: name,
    annotations: {
      'argocd.argoproj.io/sync-options': 'SkipDryRunOnMissingResource=true',
    },
  },
};

{
  GatewayClass: GatewayClass,
  Gateway: Gateway,
  HTTPRoute: HTTPRoute,
  ReferenceGrant: ReferenceGrant,

  gatewayApiGroup: gateway_group,
  gatewayApiExperimentalGroup: gateway_experimental_group,
}
