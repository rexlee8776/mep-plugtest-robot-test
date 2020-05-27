*** Settings ***

Documentation
...    A test suite for validating Timing capabilities (TIME) operations.

Resource    ../../GenericKeywords.robot
Resource    environment/variables.txt
Library     REST    ${SCHEMA}://${HOST}:${PORT}    ssl_verify=false
Library     OperatingSystem 

Default Tags    TC_MEC_SRV_TIME



*** Test Cases ***

TC_MEC_SRV_TIME_001_OK
    [Documentation]
    ...    Check that the IUT responds with timing capabilities
    ...    when queried by a MEC Application
    ...
    ...    Reference    ETSI GS MEC 011 V2.1.1, clause 7.2.5.3.1
    ...    OpenAPI    https://forge.etsi.org/rep/mec/gs011-app-enablement-api/blob/master/MecAppSupportApi.yaml#/definitions/TimingCaps

    [Tags]    PIC_MEC_PLAT    PIC_SERVICES
    Get time capabilities
    Check HTTP Response Status Code Is    200
    Check HTTP Response Body Json Schema Is    TimingCaps


TC_MEC_SRV_TIME_002_OK
    [Documentation]
    ...    Check that the IUT responds with current time
    ...    when queried by a MEC Application
    ...
    ...    Reference    ETSI GS MEC 011 V2.1.1, clause 7.2.6.3.1
    ...    OpenAPI    https://forge.etsi.org/rep/mec/gs011-app-enablement-api/blob/master/MecAppSupportApi.yaml#/definitions/CurrentTime

    [Tags]    PIC_MEC_PLAT    PIC_SERVICES
    Get current time
    Check HTTP Response Status Code Is    200
    Check HTTP Response Body Json Schema Is    CurrentTime


*** Keywords ***
Get time capabilities
    Set Headers    {"Accept":"application/json"}
    Set Headers    {"Authorization":"${TOKEN}"}
    Get    ${apiRoot}/${apiName}/${apiVersion}/timing/timing_caps
    ${output}=    Output    response
    Set Suite Variable    ${response}    ${output}

Get current time
    Set Headers    {"Accept":"application/json"}
    Set Headers    {"Authorization":"${TOKEN}"}
    Get    ${apiRoot}/${apiName}/${apiVersion}/timing/current_time
    ${output}=    Output    response
    Set Suite Variable    ${response}    ${output}