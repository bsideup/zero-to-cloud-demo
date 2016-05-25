require 'cfndsl'
require_relative 'configoHelper'

CloudFormation do
    
    Parameter("TemplateURLPrefix")
    
    Parameter("AccessKey") { NoEcho "true" }
    Parameter("SecretKey") { NoEcho "true" }
    Parameter("configoTable")
    
    Output('devURL') { Value FnGetAtt('devStack', 'Outputs.URL') }
    Output('prodURL') { Value FnGetAtt('prodStack', 'Outputs.URL') }

    ElasticBeanstalk_Application("app")

    CloudFormation_Stack("devStack") do
        TemplateURL FnJoin('', [Ref("TemplateURLPrefix"), "eb-service.json"])
        Parameters({
            :AppName => Ref("app"),
            :EnvName => "foo-dev",
            :ConfigoSource => ConfigoHelper.create_configo_dynamodb_source(["dev", "foo-dev"]),
            :InstanceType => "m3.medium"
        })
    end
    
    CloudFormation_Stack("prodStack") do
        TemplateURL FnJoin('', [Ref("TemplateURLPrefix"), "eb-service.json"])
        Parameters({ 
            :AppName => Ref("app"),
            :EnvName => "foo-prod",
            :ConfigoSource => ConfigoHelper.create_configo_dynamodb_source(["prod", "foo-prod"]),
            :RollingUpdateEnabled => "true",
            :DeploymentPolicy => "RollingWithAdditionalBatch",
            :InstanceType => "c3.large",
            :MinSize => 3,
            :MaxSize => 5
        })
    end

end