/* global jQuery */

(function($) {
    $(document).ready(function() {
        $('.js-single-selection').on('click', function(e) {
            e.preventDefault();

            var $elem = $(e.target),
                newVal;

            if ($elem.hasClass('selected')) {
                return;
            }

            $elem.siblings('a').removeClass('selected');
            $elem.addClass('selected');
            
            newVal = $elem.data('option');
            $elem.siblings('input').val(newVal)
        });
    });
})(jQuery);
