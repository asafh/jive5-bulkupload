<@resource.javascript header="true">

    var btnSubmitForApprovalText = '${action.getText('doc.create.sbmtForApprvl.button')?js_string}';
    var btnPublishText = '${action.getText('doc.create.publish.button')?js_string}';

    var isOnloadComplete = false;

    var documentViewers =   (function(){
      var obj = {};
      obj.userlists = [];
      obj.users = [];
      return obj;
  })();

    var documentAuthors =   (function(){
      var obj = {};
      obj.userlists = [];
      obj.users = [];
      return obj;
  })();

    var documentApprovers =   (function(){
      var obj = {};
      obj.userlists = [];
      obj.users = [];
      return obj;
  })();


    <#if (visibilityPolicy == statics['com.jivesoftware.visibility.VisibilityPolicy'].restricted)>
        /**
         * the documentAuthors list of users is a subset
         * of the documentViewers. Make sure that the
         * documentAuthors list contains every user
         * in the documentViewers list, but that anyone
         * who is viewer only should have the .excluded=true
         * attribute in the authors list. This will ensure
         * that those users are initially marked as crossed
         * out in the authors list
         */
        documentAuthors.users = (function (documentViewers, documentAuthors){

            function cloneUser(user){
                return {
                    displayName:user.displayName,
                    id:         user.id,
                    anonymous:  user.anonymous,
                    enabled:    user.enabled,
                    objectType: user.objectType,
                    username:   user.username,
                    email:      user.email,
                    entitled:   user.entitled,
                    avatarID:   user.avatarID
                }
            }
            // helper function
            function contains(arr, ask){
                var has = false;
                arr.forEach(function(item){
                    if(ask.id == -1){
                        has = has || (item.email == ask.email);
                    }else{
                        has = has || (item.id == ask.id && item.objectType == ask.objectType);
                    }
                });
                return has;
            }

            // create a copy of the authors array
            // that contains all the viewers
            var newAuthorsArray = [];

            // if a viewer isn't an actual author,
            // then mark them as excluded
            documentViewers.users.forEach(function(user){
                var ret = cloneUser(user);
                if(!contains(documentAuthors.users, ret)){
                    ret.excluded = true
                }
                newAuthorsArray.push(ret);
            });

            return newAuthorsArray;
        })(documentViewers, documentAuthors);
    </#if>




    function setAuthorshipPolicy(policy) {
        console.log("author policy:" + policy);
        $j('input[name="authorshipPolicy"]').each(function(i) {
            if (this.id == policy) {
                $j(this).attr('checked', 'checked');
            }
            else {
                $j(this).removeAttr('checked');
            }
        });
        if(policy != "editingPolicyClosed"){
            $j('#edit-policy-block ul.holder li.bit-box').each(function() {
                docAuthorChooser.dispose(this);
            });
        }
        if(policy == "editingPolicyPrivate") {
            if($j("#jiveViewersAsEditorsMsg").length > 0){
                $j("#jiveViewersAsEditorsMsg").hide();
            }
        }
    }

    function setVisibilityPolicy(policy) {
        console.log("visible policy:" + policy);
        $j('input[name="visibilityPolicy"]').each(function(i) {
            if (this.id == policy) {
                $j(this).attr('checked', 'checked');
            }
            else {
                $j(this).removeAttr('checked');
            }
        });
        toggleVisibilityOptions($j("#" + policy));
        toggleVisibilityRelatedOptions($j("#" + policy), true, null);
        return false;
    }

    function toggleVisibilityOptions(element){
        if($j(element).attr("value") == '${statics['com.jivesoftware.visibility.VisibilityPolicy'].owner}'){
            $j('#visibilityPolicyRestrictedPeople').hide();
            $j('#editingPolicyPrivate').attr('readonly', true);
            $j('#editingPolicyPrivate').checked = true;
            $j('#vis1info').show();
            $j('#vis3info').hide();
            $j("#jiveViewersAsEditorsMsg").hide();
        }
        if($j(element).attr("value") == '${statics['com.jivesoftware.visibility.VisibilityPolicy'].open}'){
            $j('#visibilityPolicyRestrictedPeople').hide();
            $j('#vis1info').hide();
            $j('#vis3info').hide();
            $j("#jiveViewersAsEditorsMsg").hide();
        }
        if($j(element).attr("value") == '${statics['com.jivesoftware.visibility.VisibilityPolicy'].restricted}'){
            $j('#visibilityPolicyRestrictedPeople').show();
            $j('#vis1info').hide();
            $j('#vis3info').show();
            $j("#jiveViewersAsEditorsMsg").hide();
        }
        return false;
    }

    function toggleVisibilityRelatedOptions(element, resetUsers, editingPolicy){

        var restrictedAuthorText = "<@s.text name="doc.collab.specific_users.radio"/>";
        var viewersAuthorText = "<@s.text name="doc.collab.viewers.radio"/>";
        if(editingPolicy == null){
            editingPolicy = $j(element).attr("value");
        }
        if(editingPolicy == '${statics['com.jivesoftware.visibility.VisibilityPolicy'].owner}' ||
           editingPolicy == ${statics['com.jivesoftware.community.Document'].AUTHORSHIP_SINGLE?c}){
            setAuthorshipPolicy('editingPolicyPrivate');
            window.docViewerUserPicker.reset();
            window.docAuthorUserPicker.reset();
            window.docAuthorUserPicker.hide();
            $j('#jive-extended-options-authorship').find('input').each(function() {$j(this).attr('disabled', 'disabled');});
            $j('#editingPolicyPrivate').attr('readonly', true);
            $j('#editingPolicyPrivate').checked = true;
            $j('#editingPolicyClosed ~ label').text(restrictedAuthorText);
            $j('#authorPolicyClosedPeople > a.jive-chooser-browse').hide()
        }
        if($j(element).attr("value") == '${statics['com.jivesoftware.visibility.VisibilityPolicy'].open}' ||
           editingPolicy == ${statics['com.jivesoftware.community.Document'].AUTHORSHIP_OPEN?c}){
            if(isOnloadComplete){
                setAuthorshipPolicy('editingPolicyPrivate');
                $j('#authorPolicyClosedPeople').hide();
            }
            if(resetUsers){
                window.docViewerUserPicker.reset();
                window.docAuthorUserPicker.reset();
            }
            window.docAuthorUserPicker.setNoPicker(false);
            $j('#jive-extended-options-authorship').find('input').each(function() {$j(this).removeAttr('disabled');});
            $j('#jive-extended-options-authorship').find('input').each(function() {$j(this).removeAttr('readonly');});
            $j('#editingPolicyClosed ~ label').text(restrictedAuthorText);
            $j('#authorPolicyClosedPeople > a.jive-chooser-browse').show()
        }
        if($j(element).attr("value") == '${statics['com.jivesoftware.visibility.VisibilityPolicy'].restricted}' ||
           editingPolicy == ${statics['com.jivesoftware.community.Document'].AUTHORSHIP_MULTIPLE?c}){
            if(isOnloadComplete){
                setAuthorshipPolicy('editingPolicyClosed');
                $j('#authorPolicyClosedPeople').show();
            }
            if(resetUsers){
                window.docViewerUserPicker.reset();
                window.docAuthorUserPicker.reset();
            }
            window.docAuthorUserPicker.setNoPicker(true);
            $j('#jive-extended-options-authorship').find('input').each(function() {$j(this).removeAttr('disabled');});
            $j('#jive-extended-options-authorship').find('input').each(function() {$j(this).removeAttr('readonly');});
            $j('#editingPolicyOpen').attr('disabled', 'disabled');
            $j('#editingPolicyClosed ~ label').text(viewersAuthorText);
            $j('#authorPolicyClosedPeople > a.jive-chooser-browse').hide()
        }
        return false;
    }


    $j(function() {

        /**
         * update the submit/publish button text depending on if
         * we have approvers set for this document.
         */
        function checkApproverStatus() {
            var approversStr = window.docApproverUserPicker.val();
            if (approversStr && $j.trim(approversStr).length > 0) {
                $j('#postButton').val(btnSubmitForApprovalText);
            }
            else {
                $j('#postButton').val(btnPublishText);
            }
        }

        /**
         * show or hide the "viewer has been added as an editor"
         * message after adding a new viewer to the picker
         */
        function toggleCollaboratersAddedMessage(){
            if(!$j("#editingPolicyClosed").attr("checked")){
                return;
            }
            if(window.docAuthorUserPicker.val().length > 0){
                $j("#jiveViewersAsEditorsMsg").show();
            }
            if(window.docAuthorUserPicker.val().length == 0){
                $j("#jiveViewersAsEditorsMsg").hide();
            }
        }

        /**
         * when the value of a user picker changes,
         * one of these 2 listeners will be called.
         *
         * This listener handleds the Author and Approver
         * inputs.
         */
        function authorAndApproverUserPickerListener(){
            checkApproverStatus();
            toggleCollaboratersAddedMessage();
        }

        /**
         * when a user or list is added to the visibility
         * user picker, then we also need to add them to the
         * edit picker. Then update any appropriate button
         * text
         */
        function visibilityUserPickerListener(usersAndLists){
            docAuthorUserPicker.setUsers(usersAndLists.users);
            docAuthorUserPicker.setLists(usersAndLists.userlists);
            authorAndApproverUserPickerListener();
        }

        window.docViewerUserPicker = new jive.UserPicker.Main({
            multiple: true,
            valueIsUsername: true,
            listAllowed: true,
            message: jive.UserPicker.soy.renderDocumentViewersAdded(),
            $input : $j("#documentViewers")
        });
        window.docAuthorUserPicker = new jive.UserPicker.Main({
            multiple: true,
            valueIsUsername: true,
            listAllowed: true,
            $input : $j("#documentAuthors")
        });
        window.docApproverUserPicker = new jive.UserPicker.Main({
            valueIsUsername: true,
            listAllowed: true,
            multiple: true,
            $input : $j("#documentApprovers")
        });

        // we don't initialize these in the constructor,
        // because we want the reset() function to reset these pickers
        // to empty instead of this default value
        window.docViewerUserPicker.setUsers(documentViewers.users);
        window.docViewerUserPicker.setLists(documentViewers.userlists);
        window.docAuthorUserPicker.setUsers(documentAuthors.users);
        window.docAuthorUserPicker.setLists(documentAuthors.userlists);
        window.docApproverUserPicker.setUsers(documentApprovers.users);
        window.docApproverUserPicker.setLists(documentApprovers.userlists);


        window.docViewerUserPicker.addListener("selectedUsersChanged", visibilityUserPickerListener)
        window.docAuthorUserPicker.addListener("selectedUsersChanged", authorAndApproverUserPickerListener)
        window.docApproverUserPicker.addListener("selectedUsersChanged", authorAndApproverUserPickerListener);

        /**
         * when clicking the Collaboration Options title,
         * toggle displaying those collaboration options
         */
        $j(".jive-compose-section-options h4 a").click(function() {
            $j(this).parents('header').first().next('div.jive-compose-options').toggle();
            //
            // toggling this classname on the <a> is what changes the (+) icon to a (-)
            // or vice-a-versa
            if ( $j(this).parents('header').first().next('div.jive-compose-options').is(':visible') ) {
                $j(this).removeClass('jive-compose-hdr-opt-closed').addClass('jive-compose-hdr-opt');
            } else {
                $j(this).removeClass('jive-compose-hdr-opt').addClass('jive-compose-hdr-opt-closed');
            }
            return false;
        });

        //Handle visibility changes
        <#if isUserContainer>
            toggleVisibilityOptions($j('input[name="visibilityPolicy"][value="${visibilityPolicy?js_string}"]'));
            <#if !edit>
                toggleVisibilityRelatedOptions($j('input[name="visibilityPolicy"][value="${visibilityPolicy?js_string}"]'), true);
            <#else>
                toggleVisibilityRelatedOptions($j('input[name="visibilityPolicy"][value="${visibilityPolicy?js_string}"]'), false, ${authorshipPolicy});
            </#if>
        </#if>
        isOnloadComplete = true;

        /**
         * the listener for the visibility radio
         * buttons
         */
        function visibilityPolicyRadioButtonsChanged() {
            setVisibilityPolicy(this.id);
            if ( $j("input[name='visibilityPolicy']:checked").val() == 'owner') {
                $j('#visibilityPolicyRestrictedPeople').hide();
            } else if ( $j("input[name='visibilityPolicy']:checked").val() == 'restricted') {
                $j('#visibilityPolicyRestrictedPeople').show();
            } else {
                $j('#visibilityPolicyRestrictedPeople').hide();
            }
        }

        /**
         * the listener for the author/collaborator radio
         * buttons
         */
        function authorshipPolicyRadioButtonsChanged() {
            setAuthorshipPolicy(this.id);
            if ( $j("input[name='authorshipPolicy']:checked").val() == '3') {
                $j('#authorPolicyClosedPeople').show();
            } else {
                $j('#authorPolicyClosedPeople').hide();
            }
        }

        /**
         * attach the listeners
         */
        $j('input[name="visibilityPolicy"]').change(visibilityPolicyRadioButtonsChanged);
        $j('input[name="visibilityPolicy"]').click(visibilityPolicyRadioButtonsChanged);
        $j('input[name="authorshipPolicy"]').change(authorshipPolicyRadioButtonsChanged);
        $j('input[name="authorshipPolicy"]').click(authorshipPolicyRadioButtonsChanged);

    });
</@resource.javascript>
