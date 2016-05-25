require 'cfndsl'

CloudFormation do
    
    Parameter("TemplateURLPrefix")

    DynamoDB_Table("configoTable") do
        KeySchema({ :HashKeyElement => { :AttributeName => "key", :AttributeType => "S" } })
        ProvisionedThroughput({ :ReadCapacityUnits => 1, :WriteCapacityUnits => 1 })
    end

    IAM_User("appUser") do
        Policies([
            :PolicyName => "configoDynamoDBAccess",
            :PolicyDocument => {
              :Statement => [
                { :Action => "dynamodb:*", :Effect => "Allow", :Resource => "*" }
              ]
            }
        ])
    end

    IAM_AccessKey("accessKey") { UserName Ref("appUser") }

    stacks = [
        { :name => "foo", :template => "foo-stack.json" },
        { :name => "bar", :template => "bar-stack.json" },
    ]

    for stack in stacks
        CloudFormation_Stack("#{stack[:name]}Stack") do
            TemplateURL FnJoin('', [Ref("TemplateURLPrefix"), stack[:template]])
            Parameters({
                :TemplateURLPrefix => Ref("TemplateURLPrefix"),
                :AccessKey => Ref("accessKey"),
                :SecretKey => FnGetAtt("accessKey", "SecretAccessKey"),
                :configoTable => Ref("configoTable")
            })
        end
    end

end