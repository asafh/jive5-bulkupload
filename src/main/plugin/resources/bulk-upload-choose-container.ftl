<html>
<head>
    <title>${"Choose a container"?html}</title>

    <meta name="nosidebar" content="true" />

    <content tag="breadcrumb">
        <@s.action name="community-breadcrumb" executeResult="true" ignoreContextParams="true">
            <#if container?exists>
            <@s.param name="containerType">${container.objectType?c}</@s.param>
            <@s.param name="container">${container.ID?c}</@s.param>
            </#if>
        </@s.action>
    </content>
</head>
<body class="jive-body-formpage jive-body-choose-container">

<!-- BEGIN header & intro  -->
<div id="jive-body-intro">
    <div id="jive-body-intro-content">
         <h1>Documents Bulk Upload</h1>
    </div>
</div>
<!-- END header & intro -->


<!-- BEGIN main body -->
<div id="jive-body-main">

    <!-- BEGIN main body column -->
    <div id="jive-body-maincol-container">
        <div id="jive-body-maincol">

            <!-- BEGIN formblock -->
            <div class="jive-box jive-box-form jive-standard-formblock-container">
                <div class="jive-box-body jive-standard-formblock clearfix">
					<!--osapi.jive.core.places.requestPicker({success : pickerHandler, contentType : "discussion" });-->
					<script type="text/javascript">
						(function() {
							/*var opt = {pickerContext:"create", objectType: 102, upload: true}
							var picker = new jive.Placepicker.Main();*/
							
							var placePicker = new jive.Placepicker.Main($j.extend({
							    pickerContext:"create",
							    followLinks:false,
							    objectType: 102,
							    upload: true
							    }, 102));
							placePicker.addListener("container", function(containerParams) {
								//targetContainerID, targetContainerType, and targetContainerName
								window.location.href = "/bulk-upload.jspa?containerType="+
															containerParams.targetContainerType+
															"&containerID="+
															containerParams.targetContainerID;
								//alert(JSON.stringify(containerParams));
								//bulk-upload.jspa?containerType=${container.objectType}&amp;containerID=${container.ID}
							});
							placePicker.showPicker();
							var interval = setInterval(function() { //I don't like this any bit more than you do.
								$j(".js-container-title:contains('undefined')").each(function() {
									if($j(this).text() == "undefined") {
										$j(this).text("Your documents");
									}
								});
								
								$j('.j-modal-close-top.close').click(function() {
									history.back();
								});
								if($j('.j-modal-close-top.close').length) {
									clearInterval(interval);
								}
							},${JiveGlobals.getJiveIntProperty("lp.bulk.pickerloadtime",100)?c});
						})();
					</script>
                </div>
            </div>
            <!-- END formblock -->
            </div>
        </div>
        <!-- END main body column -->
    </div>
    <!-- END main body -->
</body>
</html>