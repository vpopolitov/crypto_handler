$(function() {
    $.fn.editable.defaults.mode = 'inline';

    $('.category-title').each(function(i, obj) {
        $('#category-title-' + i).editable({ toggle: 'manual' });
        $('#category-edit-' + i).click(function (e) {
            e.stopPropagation();
            $('#category-title-' + i).editable('toggle');
        });
    });

    $('#new-category-name').editable({
        ajaxOptions: {
            type: 'post',
            beforeSend: function (xhr, settings) {
                var data = $.deparam(settings.data);
                debugger;
                data.authenticity_token = $('meta[name=csrf-token]').attr('content');
                settings.data = $.param(data);
                return true;
            },
            success: function (response, newValue) {
                alert('!!!');
            }
        },
        emptytext: '!fdfdfdfdfdfdf!!',
        emptyclass: 'custom-editable-empty',
        validate: function(value) {
            if($.trim(value) == '') return 'Необходимо заполнить это поле';
        }
    });
});