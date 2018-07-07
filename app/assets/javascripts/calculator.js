/* global jQuery */

(function($) {
    var doneCalculation = false;

    var ready = function() {
        $('[data-toggle="tooltip"]').tooltip(); 
        $('.js-single-selection').on('click', function(e) {
            e.preventDefault();

            var $elem = $(e.target),
                newVal,
                inputName;

            if ($elem.hasClass('selected')) {
                return;
            }

            $elem.siblings('a').removeClass('selected');
            $elem.addClass('selected');
            
            newVal = $elem.data('option');
            inputName = $elem.siblings('input').attr('name');

            $elem.siblings('input').val(newVal)
            
            switch(inputName) {
                case 'relationship_status':
                    if(newVal !== 'single') {
                        $('.js-children-section').show();   
                    } else {
                        $('.js-children-section').hide();
                        $('.js-children-count-section').hide();
                    }
                    break;
                case 'has_children':
                    if(newVal) {
                        $('.js-children-count-section').show();
                    } else {
                        $('.js-children-count-section').hide();
                    }
                    break;
                case 'military_service':
                    if(newVal === 'none') {
                        $('.js-military-release-date').hide();
                        $('.js-military-service-duration').hide();
                    } else {
                        $('.js-military-release-date').show();
                        $('.js-military-service-duration').show();
                    }
                    break;
                case 'education':
                    switch(newVal) {
                        case 'none':
                           $('.js-first-degree-date').hide();
                           $('.js-second-degree-date').hide();
                           break;
                        case 'first_degree':
                           $('.js-first-degree-date').show();
                           $('.js-second-degree-date').hide();
                           break;
                        case 'second_degree':
                           $('.js-first-degree-date').show();
                           $('.js-second-degree-date').show();
                           break;
                    }
                    break;
                case 'national_insurance_accepted':
                    if(newVal) {
                        $('.js-national-insurance').show();
                    } else {
                        $('.js-national-insurance').hide();
                    }
                    break;
                case 'unemployment':
                    if(newVal) {
                        $('.js-unemployment-months').show();
                    } else {
                        $('.js-unemployment-months').hide();
                    }
                    break;
            }
        });
        
        $('.js-add-child').on('click', function(e) {
            e.preventDefault();
            
            addChildRow();
        });
        
        $('.js-add-employment').on('click', function(e) {
            e.preventDefault();
            
            addEmploymentRow();
        });
        
        $('form').submit(function(event) {
            if (doneCalculation) {
                return;
            }

            event.preventDefault();
            
            $('.js-result').text ('');
            $('.result-amount').removeClass('bounce');

            $.ajax({
                type        : 'POST',
                url         : '/calculator',
                data        : $('form').serialize(),
                dataType    : 'json'
            })
            .done(function(response) {
                var amount = response.amount;
                
                $('html, body').animate({scrollTop: $(document).height()}, 'slow');

                console.log(response); 
                $('.js-result-container').show();

                if(amount == '0') {
                    $('.js-result').text('אינך זכאי להחזר מס');
                    $('.result-amount').addClass('bad-color');
                } else {
                    $('.js-result').text(response.amount + ' ש"ח');
                    $('.result-amount').addClass('bounce');
                    $('.result-amount').addClass('good-color');
                    
                    setInterval(function() {
                        doneCalculation = true;
                        $('form').submit();
                    }, 2000);
                }
            });
        });
    };

    $(document).on('turbolinks:load', ready);
    
    var addChildRow = function() {
        var index = $('.js-children-dates-table tr').length + 1;
        $('.js-children-dates-table tr:last').after(
            '<tr><td>' + index + '</td><td><input type="date" min="2012-01-01" max="2017-12-31" name="child_birth_date[' + (index-1) + ']"></td></tr>'
        );
    }
    
    var addEmploymentRow = function() {
        var index = $('.js-employment-table tr').length;
        $('.js-employment-table tr:last').after(
            '<tr>\
                <td>' + index + '</td>\
                <td><input type="number" name="employment[' + (index-1) + '][salary]"></td>\
                <td><input type="number" name="employment[' + (index-1) + '][contribution]"></td>\
                <td><input type="number" name="employment[' + (index-1) + '][tax]"></td>\
            </tr>'
        );
    }
})(jQuery);
