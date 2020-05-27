*** Settings ***

Documentation
...    A test suite for validating DNS rules (DNS) operations.

Resource    ../../GenericKeywords.robot
Resource    environment/variables.txt
Library     REST    ${SCHEMA}://${HOST}:${PORT}    ssl_verify=false
Library     OperatingSystem 

Default Tags    TC_MEC_SRV_DNS


*** Variables ***


*** Test Cases ***

TC_MEC_SRV_DNS_001_OK
    [Documentation]
    ...    Check that the IUT responds with a list of active DNS rules
    ...    when queried by a MEC Application
    ...
    ...    Reference    ETSI GS MEC 011 V2.1.1, clause 7.2.9.3.1
    ...    OpenAPI    https://forge.etsi.org/rep/mec/gs011-app-enablement-api/blob/master/MecAppSupportApi.yaml#/definitions/DnsRule

    [Tags]    PIC_MEC_PLAT    PIC_SERVICES
    Get list of active DNS rules    ${APP_INSTANCE_ID}
    Check HTTP Response Status Code Is    200
    Check HTTP Response Body Json Schema Is    DnsRuleList


TC_MEC_SRV_DNS_002_OK
    [Documentation]
    ...    Check that the IUT responds with the information on a specific DNS rule
    ...    when queried by a MEC Application
    ...
    ...    Reference    ETSI GS MEC 011 V2.1.1, clause 7.2.10.3.1
    ...    OpenAPI    https://forge.etsi.org/rep/mec/gs011-app-enablement-api/blob/master/MecAppSupportApi.yaml#/definitions/DnsRule

    [Tags]    PIC_MEC_PLAT    PIC_SERVICES
    Get individual DNS rule    ${APP_INSTANCE_ID}    ${DNS_RULE_ID}
    Check HTTP Response Status Code Is    200
    Check HTTP Response Body Json Schema Is    DnsRule
    Check Result Contains    ${response['body']}    dnsRuleId    ${DNS_RULE_ID}


TC_MEC_SRV_DNS_002_NF
    [Documentation]
    ...    Check that the IUT responds with an error when
    ...    a request for an unknown URI is sent by a MEC Application
    ...
    ...    Reference    ETSI GS MEC 011 V2.1.1, clause 7.2.10.3.1

    [Tags]    PIC_MEC_PLAT    PIC_SERVICES
    Get individual DNS rule    ${APP_INSTANCE_ID}    ${NON_ESISTENT_DNS_RULE_ID}
    Check HTTP Response Status Code Is    404


TC_MEC_SRV_DNS_003_OK
    [Documentation]
    ...    Check that the IUT updates a specific DNS rule
    ...    when commanded by a MEC Application
    ...
    ...    Reference    ETSI GS MEC 011 V2.1.1, clause 7.2.10.3.2
    ...    OpenAPI    https://forge.etsi.org/rep/mec/gs011-app-enablement-api/blob/master/MecAppSupportApi.yaml#/definitions/DnsRule

    [Tags]    PIC_MEC_PLAT    PIC_SERVICES
    Update a DNS Rule    ${APP_INSTANCE_ID}    ${DNS_RULE_ID}    DnsRuleUpdate
    Check HTTP Response Status Code Is    200
    Check HTTP Response Body Json Schema Is    DnsRule
    Check Result Contains    ${response['body']}    ipAddress    ${SOME_IP_ADDRESS}


TC_MEC_SRV_DNS_003_BR
    [Documentation]
    ...    Check that the IUT responds with an error when
    ...    a request with incorrect parameters is sent by a MEC Application
    ...
    ...    Reference    ETSI GS MEC 011 V2.1.1, clause 7.2.10.3.2
    ...    OpenAPI    https://forge.etsi.org/rep/mec/gs011-app-enablement-api/blob/master/MecAppSupportApi.yaml#/definitions/DnsRule

    [Tags]    PIC_MEC_PLAT    PIC_SERVICES
    Update a DNS Rule    ${APP_INSTANCE_ID}    ${DNS_RULE_ID}    DnsRuleUpdateError
    Check HTTP Response Status Code Is    400


TC_MEC_SRV_DNS_003_NF
    [Documentation]
    ...    Check that the IUT responds with an error when
    ...    a request for an unknown URI is sent by a MEC Application
    ...
    ...    Reference    ETSI GS MEC 011 V2.1.1, clause 7.2.10.3.2
    ...    OpenAPI    https://forge.etsi.org/rep/mec/gs011-app-enablement-api/blob/master/MecAppSupportApi.yaml#/definitions/DnsRule

    [Tags]    PIC_MEC_PLAT    PIC_SERVICES
    Update a DNS Rule    ${APP_INSTANCE_ID}    ${NON_ESISTENT_DNS_RULE_ID}    DnsRuleUpdate
    Check HTTP Response Status Code Is    404


TC_MEC_SRV_DNS_003_PF
    [Documentation]
    ...    Check that the IUT responds with an error when
    ...    a request sent by a MEC Application doesn't comply with a required condition
    ...
    ...    Reference    ETSI GS MEC 011 V2.1.1, clause 7.2.10.3.2
    ...    OpenAPI    https://forge.etsi.org/rep/mec/gs011-app-enablement-api/blob/master/MecAppSupportApi.yaml#/definitions/DnsRule

    [Tags]    PIC_MEC_PLAT    PIC_SERVICES
    Update a DNS Rule with invalid etag    ${APP_INSTANCE_ID}    ${DNS_RULE_ID}    DnsRuleUpdate
    Check HTTP Response Status Code Is    412



*** Keywords ***
Get list of active DNS rules    
    [Arguments]    ${appInstanceId}
    Set Headers    {"Accept":"application/json"}
    Set Headers    {"Authorization":"${TOKEN}"}
    Get    ${apiRoot}/${apiName}/${apiVersion}/applications/${appInstanceId}/dns_rules
    ${output}=    Output    response
    Set Suite Variable    ${response}    ${output}


Get individual DNS rule    
    [Arguments]    ${appInstanceId}    ${dnsRuleId}
    Set Headers    {"Accept":"application/json"}
    Set Headers    {"Authorization":"${TOKEN}"}
    Get    ${apiRoot}/${apiName}/${apiVersion}/applications/${appInstanceId}/dns_rules/${dnsRuleId}
    ${output}=    Output    response
    Set Suite Variable    ${response}    ${output}
    
Update a DNS Rule
    [Arguments]    ${appInstanceId}    ${dnsRuleId}    ${content}
    Set Headers    {"Accept":"application/json"}
    Set Headers    {"Content-Type":"application/json"}
    Set Headers    {"Authorization":"${TOKEN}"}
    ${file}=    Catenate    SEPARATOR=    jsons/    ${content}    .json
    ${body}=    Get File    ${file}
    PUT    ${apiRoot}/${apiName}/${apiVersion}/applications/${appInstanceId}/dns_rules/${dnsRuleId}    ${body}
    ${output}=    Output    response
    Set Suite Variable    ${response}    ${output}
    
Update a DNS Rule with invalid etag
    [Arguments]    ${appInstanceId}    ${dnsRuleId}    ${content}
    Set Headers    {"If-Match": ${INVALID_ETAG}}
    Update a DNS Rule    ${appInstanceId}    ${dnsRuleId}    ${content}