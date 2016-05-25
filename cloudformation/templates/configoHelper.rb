require 'cfndsl'

class ConfigoHelper
    def self.create_configo_dynamodb_source(keys)
        CloudFormation do
            sources = keys.map! { |key| 
                {
                    :type => "dynamodb",
                    :accessKey => '!!!AccessKey!!!',
                    :secretKey => '!!!SecretKey!!!',
                    :region => "!!!AWS::Region!!!",
                    :table => '!!!configoTable!!!',
                    :key => key
                }
            }

            parts = JSON.generate({ :type => "composite", :sources => sources })
                .split("!!!")
                .map! { |el| case el when "AccessKey", "SecretKey", "AWS::Region", "configoTable" then Ref(el) else el end }

            return FnJoin('', parts)
        end
    end
end