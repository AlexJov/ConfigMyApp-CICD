def label = "worker-${UUID.randomUUID().toString()}"

properties(
 // [pipelineTriggers([githubPush()])]
  [parameters(
    [
      string(defaultValue: 'PS_Kong', description: '', name: 'CMA_APPLICATION_NAME', trim: false),
      choice(choices: ['saas.appd-cx.com'], description: 'Select AppDynamics Controller', name: 'CMA_CONTROLLER_HOST'),
      choice(choices: ['customer1', 'fieldlabs'], description: 'Select AppDynamics Account', name: 'CMA_ACCOUNT'),
      string(defaultValue: '8090', description: 'Controller Port', name: 'CMA_CONTROLLER_PORT', trim: true),
      booleanParam(defaultValue: 'true', description: 'Use HTTPS?', name: 'CMA_USE_HTTPS', trim: false),
      booleanParam(defaultValue: false, description: 'Include Server visibility', name: 'CMA_INCLUDE_SIM'),
      booleanParam(defaultValue: false, description: 'Configure ONLY Buisness transactions', name: 'CMA_BT_ONLY'),
      booleanParam(defaultValue: false, description: 'Add Business Transactions', name: 'CMA_CONFIGURE_BT'),
      booleanParam(defaultValue: false, description: 'Include Database', name: 'CMA_INCLUDE_DATABASE'),
      string(defaultValue: 'ConfigMyApp', description: 'If Include DB, set DB collector name', name: 'CMA_DATABASE_NAME', trim: false),
      booleanParam(defaultValue: false, description: 'Overwrite Existing Health Rules', name: 'CMA_OVERWRITE_HEALTH_RULES'),
      booleanParam(defaultValue: true, description: 'Configure only Health Rules', name: 'CMA_HEALTH_RULES_ONLY'),
      booleanParam(defaultValue: false, description: 'Create default dashboard?', name: 'CMA_UPLOAD_DEFAULT_DASHBOARD'),
      booleanParam(defaultValue: true, description: 'Upload custom dashboard?', name: 'CMA_UPLOAD_CUSTOM_DASHBOARD')

    ])
  ]
)

node {
     // Clean workspace before doing anything...
    deleteDir()
  try {
      stage ('Clone') { 
         checkout scm
        }
       stage('ConfigMyApp') {  
           withCredentials([usernamePassword(credentialsId: 'kong_controller_credentials', passwordVariable: 'CMA_PASSWORD', usernameVariable: 'CMA_USERNAME')]) {
            sh """
            echo "ConfigMyApp..start"  
            export CMA_APPLICATION_NAME=${params.CMA_APPLICATION_NAME}
            export CMA_CONTROLLER_HOST=${params.CMA_CONTROLLER_HOST}
            export CMA_USE_HTTPS=${params.CMA_USE_HTTPS}
            export CMA_CONTROLLER_PORT=${params.CMA_CONTROLLER_PORT}
            export CMA_BT_ONLY=${params.CMA_BT_ONLY}
            export CMA_ACCOUNT=${params.CMA_ACCOUNT}
            export CMA_INCLUDE_SIM=${params.CMA_INCLUDE_SIM}
            export CMA_CONFIGURE_BT=${params.CMA_CONFIGURE_BT}
            export CMA_INCLUDE_DATABASE=${params.CMA_INCLUDE_DATABASE}
            export CMA_HEALTH_RULES_ONLY=${params.CMA_HEALTH_RULES_ONLY}
            export CMA_OVERWRITE_HEALTH_RULES=${params.CMA_OVERWRITE_HEALTH_RULES}
            export CMA_UPLOAD_DEFAULT_DASHBOARD=${params.CMA_UPLOAD_DEFAULT_DASHBOARD}
            export CMA_UPLOAD_CUSTOM_DASHBOARD=${params.CMA_UPLOAD_CUSTOM_DASHBOARD}


            LOCATION=\$(curl -s https://api.github.com/repos/CiscoDevNet/ConfigMyApp/releases/latest \
            | grep "tag_name" \
            | awk '{print "https://github.com/CiscoDevNet/ConfigMyApp/archive/" substr(\$2, 2, length(\$2)-3) ".zip"}') \
            ; curl -L -o ConfigMyApp.zip \$LOCATION

            ls -ltr

            echo "USER >>> \$CMA_UERNAME"

            # apt-get install unzip -y drgrdtrtr
            unzip ConfigMyApp.zip
            cd ConfigMyApp-* 

            #Branding...
            background="https://user-images.githubusercontent.com/2548160/94803698-99ee7a80-03e1-11eb-9bff-5ed9b89eefec.jpg"
            curl -o "branding/background.jpg" \$background 
            logo="https://user-images.githubusercontent.com/23483887/131845401-7f98a4c2-a177-405e-9f6e-f27f8e22a13e.png"
            curl -o "branding/logo.png" \$logo 
      
            pwd

            ls ${workspace}

            if [ "\$CMA_BT_ONLY" = true ] || [ "\$CMA_CONFIGURE_BT" = true ]; then
              cp ${workspace}/bt_config/${params.CMA_APPLICATION_NAME}-configBT.json bt_config/configBT.json
            fi
            
            if [ "\$CMA_UPLOAD_CUSTOM_DASHBOARD" = true ]; then
              echo "Copying dahboard files..."
              rm -r custom_dashboards/*
              cp -r ${workspace}/custom_dashboards/${params.CMA_APPLICATION_NAME}/* custom_dashboards/
              ls custom_dashboards/
              ./start.sh --upload-custom-dashboard --no-upload-default-dashboard
              exit 0
            fi

            if [ "\$CMA_HEALTH_RULES_ONLY" = true ]; then
              echo "Copying health rules files..."
              rm -r health_rules/*
              cp -r ${workspace}/health_rules/${params.CMA_APPLICATION_NAME}/* health_rules/
              ls health_rules/
              ./start.sh --logo-name="logo.png" --background-name="background.jpg"
              exit 0
            fi

            echo "Start script"
            if [ "\$CMA_INCLUDE_DATABASE" = true ]; then 
              ./start.sh  --include-database --database-name='${params.CMA_DATABASE_NAME}' --overwrite-health-rules  --logo-name="logo.png" --background-name="background.jpg"
            else
              ./start.sh --overwrite-health-rules  --logo-name="logo.png" --background-name="background.jpg"
            fi
            echo "End script"
          """
      }
      }
    }catch (err) {
        currentBuild.result = 'FAILED'
        throw err
    }
    
 } 

 

