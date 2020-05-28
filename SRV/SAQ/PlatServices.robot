*** Settings ***

Documentation
...    A test suite for validating Service Availability Query (SAQ) operations.

Resource    ../../GenericKeywords.robot
Resource    environment/variables.txt
Library     REST    ${SCHEMA}://${HOST}:${PORT}    ssl_verify=false
Library     OperatingSystem  

Default Tags    TC_MEC_SRV_SAQ



*** Test Cases ***

TC_MEC_SRV_SAQ_001_OK
    [Documentation]
    ...    Check that the IUT responds with a list of available MEC services
    ...    when queried by a MEC Application
    ...
    ...    Reference    ETSI GS MEC 011 V2.1.1, clause 8.2.3.3.1
    ...    OpenAPI    https://forge.etsi.org/rep/mec/gs011-app-enablement-api/blob/master/MecServiceMgmtApi.yaml#/definitions/ServiceInfoList

    [Tags]    PIC_MEC_PLAT    PIC_SERVICES
    Get list of available MEC services
    Check HTTP Response Status Code Is    200
    Check HTTP Response Body Json Schema Is    ServiceInfoList


TC_MEC_SRV_SAQ_001_BR
    [Documentation]
    ...    Check that the IUT responds with an error when
    ...    a request with incorrect parameters is sent by a MEC Application
    ...
    ...    Reference    ETSI GS MEC 011 V2.1.1, clause 8.2.3.3.1

    [Tags]    PIC_MEC_PLAT    PIC_SERVICES
    Get list of available MEC services with parameters    instance_id    ${INVALID_VALUE}
    Check HTTP Response Status Code Is    400


TC_MEC_SRV_SAQ_002_OK
    [Documentation]
    ...    Check that the IUT responds with the information on a specific service
    ...    when queried by a MEC Application
    ...
    ...    Reference    ETSI GS MEC 011 V2.1.1, clause 8.2.4.3.1
    ...    OpenAPI    https://forge.etsi.org/rep/mec/gs011-app-enablement-api/blob/master/MecServiceMgmtApi.yaml#/definitions/ServiceInfoList

    [Tags]    PIC_MEC_PLAT    PIC_SERVICES
    Get specific MEC service    ${SERVICE_ID}
    Check HTTP Response Status Code Is    200
    Check HTTP Response Body Json Schema Is    ServiceInfo
    Check Result Contains    ${response['body']}    serInstanceId    ${SERVICE_ID}


TC_MEC_SRV_SAQ_002_NF
    [Documentation]
    ...    Check that the IUT responds with an error when
    ...    a request for an unknown URI is sent by a MEC Application
    ...
    ...    Reference    ETSI GS MEC 011 V2.1.1, clause 8.2.4.3.1

    [Tags]    PIC_MEC_PLAT    PIC_SERVICES
    Get specific MEC service    ${NON_EXISTENT_SERVICE_ID}
    Check HTTP Response Status Code Is    404


*** Keywords ***
Get list of available MEC services with parameters
    [Arguments]    ${key}=None    ${value}=None
    Set Headers    {"Accept":"application/json"}
    Set Headers    {"Authorization":"${TOKEN}"}
    Get    ${apiRoot}/${apiName}/${apiVersion}/services?${key}=${value}
    ${output}=    Output    response
    Set Suite Variable    ${response}    ${output}
    
Get list of available MEC services
    Set Headers    {"Accept":"application/json"}
    Set Headers    {"Authorization":"${TOKEN}"}
    Get    ${apiRoot}/${apiName}/${apiVersion}/services
    ${output}=    Output    response
    Set Suite Variable    ${response}    ${output}
    
Get specific MEC service
    [Arguments]    ${serviceId}
    Set Headers    {"Accept":"application/json"}
    Set Headers    {"Authorization":"${TOKEN}"}
    Get    ${apiRoot}/${apiName}/${apiVersion}/services/${serviceId}
    ${output}=    Output    response
    Set Suite Variable    ${response}    ${output}