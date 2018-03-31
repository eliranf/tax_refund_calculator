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
                    if(newVal === 'married') {
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
            }
        });
    });
})(jQuery);
