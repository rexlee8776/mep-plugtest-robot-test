*** Settings ***

Documentation
...    A test suite for validating Traffic rules (TRAF) operations.

Resource    ../../GenericKeywords.robot
Resource    environment/variables.txt
Library     REST    ${SCHEMA}://${HOST}:${PORT}    ssl_verify=false
Library     OperatingSystem 

Default Tags    TC_MEC_SRV_TRAF


*** Test Cases ***

TC_MEC_SRV_TRAF_001_OK
    [Documentation]
    ...    Check that the IUT responds with a list of available traffic rules
    ...    when queried by a MEC Application
    ...
    ...    Reference    ETSI GS MEC 011 V2.1.1, clause 7.2.7.3.1
    ...    OpenAPI    https://forge.etsi.org/rep/mec/gs011-app-enablement-api/blob/master/MecAppSupportApi.yaml#/definitions/TrafficRule

    [Tags]    PIC_MEC_PLAT    PIC_SERVICES
    Get list of traffic rules    ${APP_INSTANCE_ID}
    Check HTTP Response Status Code Is    200
    Check HTTP Response Body Json Schema Is    TrafficRuleList


TC_MEC_SRV_TRAF_001_NF
    [Documentation]
    ...    Check that the IUT responds with an error when
    ...    a request for an unknown URI is sent by a MEC Application
    ...
    ...    Reference    ETSI GS MEC 011 V2.0.9, clause 7.2.8.3.1

    [Tags]    PIC_MEC_PLAT    PIC_SERVICES
    Get list of traffic rules    ${NON_EXISTENT_APP_INSTANCE_ID}
    Check HTTP Response Status Code Is    404


TC_MEC_SRV_TRAF_002_OK
    [Documentation]
    ...    Check that the IUT responds with the information on a specific traffic rule
    ...    when queried by a MEC Application
    ...
    ...    Reference    ETSI GS MEC 011 V2.1.1, clause 7.2.8.3.1
    ...    OpenAPI    https://forge.etsi.org/rep/mec/gs011-app-enablement-api/blob/master/MecAppSupportApi.yaml#/definitions/TrafficRule

    [Tags]    PIC_MEC_PLAT    PIC_SERVICES
    Get individual traffic rule    ${APP_INSTANCE_ID}    ${TRAFFIC_RULE_ID}
    Check HTTP Response Status Code Is    200
    Check HTTP Response Body Json Schema Is    TrafficRule
    Check Result Contains    ${response['body']}    trafficRuleId    ${TRAFFIC_RULE_ID}


TC_MEC_SRV_TRAF_003_OK
    [Documentation]
    ...    Check that the IUT updates a specific traffic rule
    ...    when commanded by a MEC Application
    ...
    ...    Reference    ETSI GS MEC 011 V2.1.1, clause 7.2.8.3.2
    ...    OpenAPI    https://forge.etsi.org/rep/mec/gs011-app-enablement-api/blob/master/MecAppSupportApi.yaml#/definitions/TrafficRule

    [Tags]    PIC_MEC_PLAT    PIC_SERVICES
    Update a traffic rule    ${APP_INSTANCE_ID}    ${TRAFFIC_RULE_ID}    TrafficRuleUpdate
    Check HTTP Response Status Code Is    200
    Check HTTP Response Body Json Schema Is    TrafficRule
    Check Result Contains    ${response['body']}    trafficRuleId    ${TRAFFIC_RULE_ID} 
    Check Result Contains    ${response['body']}    action    "DROP"


TC_MEC_SRV_TRAF_003_BR
    [Documentation]
    ...    Check that the IUT responds with an error when
    ...    a request with incorrect parameters is sent by a MEC Application
    ...
    ...    Reference    ETSI GS MEC 011 V2.1.1, clause 7.2.8.3.2
    ...    OpenAPI    https://forge.etsi.org/rep/mec/gs011-app-enablement-api/blob/master/MecAppSupportApi.yaml#/definitions/TrafficRule

    [Tags]    PIC_MEC_PLAT    PIC_SERVICES
    Update a traffic rule    ${APP_INSTANCE_ID}    ${TRAFFIC_RULE_ID}    TrafficRuleUpdateError
    Check HTTP Response Status Code Is    400


TC_MEC_SRV_TRAF_003_NF
    [Documentation]
    ...    Check that the IUT responds with an error when
    ...    a request for an unknown URI is sent by a MEC Application
    ...
    ...    Reference    ETSI GS MEC 011 V2.1.1, clause 7.2.8.3.2
    ...    OpenAPI    https://forge.etsi.org/rep/mec/gs011-app-enablement-api/blob/master/MecAppSupportApi.yaml#/definitions/TrafficRule

    [Tags]    PIC_MEC_PLAT    PIC_SERVICES
    Update a traffic rule    ${APP_INSTANCE_ID}    ${NON_EXISTENT_TRAFFIC_RULE_ID}    TrafficRuleUpdate
    Check HTTP Response Status Code Is    404


TC_MEC_SRV_TRAF_003_PF
    [Documentation]
    ...    Check that the IUT responds with an error when
    ...    a request sent by a MEC Application doesn't comply with a required condition
    ...
    ...    Reference    ETSI GS MEC 011 V2.1.1, clause 7.2.8.3.2
    ...    OpenAPI    https://forge.etsi.org/rep/mec/gs011-app-enablement-api/blob/master/MecAppSupportApi.yaml#/definitions/TrafficRule

    [Tags]    PIC_MEC_PLAT    PIC_SERVICES
    Update a traffic rule with invalid etag   ${APP_INSTANCE_ID}    ${TRAFFIC_RULE_ID}    TrafficRuleUpdate
    Check HTTP Response Status Code Is    412

*** Keywords ***
Get list of traffic rules   
    [Arguments]     ${appInstanceId}
    Set Headers    {"Accept":"application/json"}
    Set Headers    {"Authorization":"${TOKEN}"}
    Get    ${apiRoot}/${apiName}/${apiVersion}/applications/${appInstanceId}/traffic_rules
    ${output}=    Output    response
    Set Suite Variable    ${response}    ${output}
    
Get individual traffic rule    
    [Arguments]     ${appInstanceId}    ${trafficRuleId}
    Set Headers    {"Accept":"application/json"}
    Set Headers    {"Authorization":"${TOKEN}"}
    Get    ${apiRoot}/${apiName}/${apiVersion}/applications/${appInstanceId}/traffic_rules/${trafficRuleId}
    ${output}=    Output    response
    Set Suite Variable    ${response}    ${output}
    
Update a traffic rule    
    [Arguments]    ${appInstanceId}    ${trafficRuleId}    ${content}
    Set Headers    {"Accept":"application/json"}
    Set Headers    {"Content-Type":"application/json"}
    Set Headers    {"Authorization":"${TOKEN}"}
    ${file}=    Catenate    SEPARATOR=    jsons/    ${content}    .json
    ${body}=    Get File    ${file}
    PUT    ${apiRoot}/${apiName}/${apiVersion}/applications/${appInstanceId}/traffic_rules/${trafficRuleId}    ${body}
    ${output}=    Output    response
    Set Suite Variable    ${response}    ${output}
    
Update a traffic rule with invalid etag
    [Arguments]    ${appInstanceId}    ${trafficRuleId}    ${content}
    Set Headers    {"If-Match": "${INVALID_ETAG}"}
    Update a traffic rule    ${appInstanceId}    ${trafficRuleId}    ${content}