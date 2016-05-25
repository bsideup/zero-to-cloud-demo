require 'cfndsl'

CloudFormation do
    Description "AWS EB microservice"
    
    Parameter("EnvName")
    Parameter("AppName")
    Parameter("ConfigoSource")
    Parameter("HealthcheckURL") { Default "/health" }

    Parameter("RollingUpdateEnabled") do
        Default "false"
        AllowedValues [ "false", "true" ]
    end

    Parameter("DeploymentPolicy") do 
        Default "AllAtOnce"
        AllowedValues [ "AllAtOnce", "Rolling", "RollingWithAdditionalBatch", "Immutable" ]
    end

    Parameter("InstanceType") do
        Default "m1.small"
        AllowedValues [ "t2.micro", "m1.small", "t2.small", "m3.medium", "c3.large" ]
    end
    
    Parameter("MinSize") do
        Type "Number"
        Default 1
    end
    
    Parameter("MaxSize") do
        Type "Number"
        Default 1
    end

    Output('URL') { Value FnGetAtt('env', 'EndpointURL') }

    ElasticBeanstalk_Environment("env") do
        EnvironmentName Ref("EnvName")
        ApplicationName Ref("AppName")
        SolutionStackName "64bit Amazon Linux 2016.03 v2.1.0 running Docker 1.9.1"
        OptionSettings [
            { Namespace: "aws:autoscaling:launchconfiguration", OptionName: "InstanceType", Value: Ref("InstanceType") },
            
            { Namespace: "aws:autoscaling:asg", OptionName: "MinSize", Value: Ref("MinSize") },
            { Namespace: "aws:autoscaling:asg", OptionName: "MaxSize", Value: Ref("MaxSize") },

            { Namespace: "aws:elasticbeanstalk:application:environment", OptionName: "CONFIGO_SOURCE_0", Value: Ref("ConfigoSource") },

            { Namespace: "aws:elasticbeanstalk:command", OptionName: "DeploymentPolicy", Value: Ref("DeploymentPolicy") },
            { Namespace: "aws:elasticbeanstalk:command", OptionName: "BatchSize", Value: "100" },

            { Namespace: "aws:autoscaling:trigger", OptionName: "MeasureName", Value: "CPUUtilization" },
            { Namespace: "aws:autoscaling:trigger", OptionName: "Unit", Value: "Percent" },
            { Namespace: "aws:autoscaling:trigger", OptionName: "LowerThreshold", Value: "40" },
            { Namespace: "aws:autoscaling:trigger", OptionName: "UpperThreshold", Value: "70" },

            { Namespace: "aws:autoscaling:updatepolicy:rollingupdate", OptionName: "RollingUpdateEnabled", Value: Ref("RollingUpdateEnabled") },
            { Namespace: "aws:autoscaling:updatepolicy:rollingupdate", OptionName: "PauseTime", Value: "PT0S" },
            { Namespace: "aws:autoscaling:updatepolicy:rollingupdate", OptionName: "RollingUpdateType", Value: "Health" },

            { Namespace: "aws:elasticbeanstalk:application", OptionName: "Application Healthcheck URL", Value: Ref("HealthcheckURL") }
        ]
    end
end