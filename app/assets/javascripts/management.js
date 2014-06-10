$(document).ready(function() {

  var paypal_email = $("#tour_operator_paypal_email").val();

  if ($('#tour_operator_embed_terms_and_conditions').attr('checked')) {
    $("#embed_flow").show();
  }
  
  $('#tour_operator_embed_terms_and_conditions').click(function() {
    $("#embed_flow").toggle();
    if (!$('#tour_operator_embed_terms_and_conditions').attr('checked')) {
    	$("#tour_operator_paypal_email").val("");
    }  
    else {
    	$("#tour_operator_paypal_email").val(paypal_email);
    }
  });
  
  $("a[class=tandc]").click(function(e){
    e.preventDefault();
    window.open($(this).attr("href"), "", 'top=50, left=50, width=500, height=400, location=0, status=0, toolbar=0, menubar=0, resizable=0, scrollbars=1');          
  });
  
  //TODO I think this is old...
  $('a.new').click(function(){
    url = $(this).attr('href');
    $.get(url, function(data){
      appendContent(data)
    });
    return false;
  });

  $('a.edit_tour_operator').live('click', function() {
    currentDiv = $(this).closest('.row');
    url = $(this).attr('href');
    $.get(url, function(data){
      currentDiv.after(data);
      currentDiv.hide();
    });
    return false;
  });
/*  
  $('a.edit_product').live('click', function() {
    currentDiv = $(this).closest('.row');
    url = $(this).attr('href');
    $.get(url, function(data){
      currentDiv.after(data);
      currentDiv.hide();
    });
    return false;
  });
  */
 
  $('a.details-product').live('click', function() {
    $(this).parent().siblings('.details').toggle();
    return false;
  });
  
  $('a.cancel').live('click', function() {
    $('#' + $(this).data('view-id')).show();
    $('#edit_' + $(this).data('view-id')).remove();
    //$('.form').remove();
    //removeForm();
    return false;
  });
})


function removeForm() {
  $('.form').remove();
}

function appendContent(content){
  $('.body-div').append(content);
}

