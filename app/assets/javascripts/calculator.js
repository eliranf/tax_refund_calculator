/* global jQuery */

(function($) {
    $(document).ready(function() {
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
    });
    
    var addChildRow = function() {
        var index = $('.js-children-dates-table tr').length + 1;
        $('.js-children-dates-table tr:last').after(
            '<tr><td>' + index + '</td><td><input type="date" name="child_birth_date[' + (index-1) + ']"></td></tr>'
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
                <td><input type="date" name="employment[' + (index-1) + '][start_date]"></td>\
                <td><input type="date" name="employment[' + (index-1) + '][end_date]"></td>\
            </tr>'
        );
    }
})(jQuery);
