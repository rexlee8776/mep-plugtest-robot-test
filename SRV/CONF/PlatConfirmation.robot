*** Settings ***

Documentation
...    A test suite for validating DNS rules (DNS) operations.

Resource    ../../GenericKeywords.robot
Resource    environment/variables.txt
Library     REST    ${SCHEMA}://${HOST}:${PORT}    ssl_verify=false
Library     OperatingSystem 

Default Tags    TC_MEC_SRV_CONF


*** Variables ***


*** Test Cases ***

TC_MEC_SRV_CONF_001_OK
    [Documentation]
    ...    Check that the IUT responds with an acknowledge
    ...    when requested graceful termination/stop of a MEC Application instance
    ...
    ...    Reference    ETSI GS MEC 011 V2.1.1, clause 7.2.11.3.4
    ...    OpenAPI    https://forge.etsi.org/rep/mec/gs011-app-enablement-api/blob/master/MecAppSupportApi.yaml#/definitions/AppTerminationConfirmation

    [Tags]    PIC_MEC_PLAT    PIC_SERVICES
    Request termination of MEC Application    ${APP_INSTANCE_ID}    AppTerminationConfirmation
    Check HTTP Response Status Code Is    204


TC_MEC_SRV_CONF_001_NF
    [Documentation]
    ...    Check that the IUT responds with an error
    ...    when requested graceful termination/stop of an unknown MEC Application instance
    ...
    ...    Reference    ETSI GS MEC 011 V2.1.1, clause 7.2.11.3.4
    ...    OpenAPI    https://forge.etsi.org/rep/mec/gs011-app-enablement-api/blob/master/MecAppSupportApi.yaml#/definitions/AppTerminationConfirmation

    [Tags]    PIC_MEC_PLAT    PIC_SERVICES
    Request termination of MEC Application    ${NON_ESISTENT_APP_INSTANCE_ID}    AppTerminationConfirmation
    Check HTTP Response Status Code Is    404
    



TC_MEC_SRV_CONF_002_OK
    [Documentation]
    ...    Check that the IUT responds with an acknowledge
    ...    when requested readiness status for a MEC Application instance
    ...
    ...    Reference    ETSI GS MEC 011 V2.1.1, clause 7.2.12.3.4
    ...    OpenAPI    https://forge.etsi.org/rep/mec/gs011-app-enablement-api/blob/master/MecAppSupportApi.yaml#/definitions/AppReadyConfirmation

    [Tags]    PIC_MEC_PLAT    PIC_SERVICES
    Request readiness status of MEC Application    ${APP_INSTANCE_ID}    AppReadyConfirmation
    Check HTTP Response Status Code Is    204


TC_MEC_SRV_CONF_002_NF
    [Documentation]
    ...    Check that the IUT responds with an error
    ...    when requested readiness status for an unknown MEC Application instance
    ...
    ...    Reference    ETSI GS MEC 011 V2.1.1, clause 7.2.12.3.4
    ...    OpenAPI    https://forge.etsi.org/rep/mec/gs011-app-enablement-api/blob/master/MecAppSupportApi.yaml#/definitions/AppReadyConfirmation

    [Tags]    PIC_MEC_PLAT    PIC_SERVICES
    Request readiness status of MEC Application    ${NON_ESISTENT_APP_INSTANCE_ID}   AppReadyConfirmation
    Check HTTP Response Status Code Is    404


*** Keywords ***
Request termination of MEC Application
    [Arguments]    ${appInstanceId}    ${content}
    Set Headers    {"Accept":"application/json"}
    Set Headers    {"Content-Type":"application/json"}
    Set Headers    {"Authorization":"${TOKEN}"}
    ${file}=    Catenate    SEPARATOR=    jsons/    ${content}    .json
    ${body}=    Get File    ${file}
    PUT    ${apiRoot}/${apiName}/${apiVersion}/applications/${appInstanceId}/confirm_termination    ${body}
    ${output}=    Output    response
    Set Suite Variable    ${response}    ${output}
    

Request readiness status of MEC Application
    [Arguments]    ${appInstanceId}    ${content}
    Set Headers    {"Accept":"application/json"}
    Set Headers    {"Content-Type":"application/json"}
    Set Headers    {"Authorization":"${TOKEN}"}
    ${file}=    Catenate    SEPARATOR=    jsons/    ${content}    .json
    ${body}=    Get File    ${file}
    PUT    ${apiRoot}/${apiName}/${apiVersion}/applications/${appInstanceId}/confirm_ready    ${body}
    ${output}=    Output    response
    Set Suite Variable    ${response}    ${output}
