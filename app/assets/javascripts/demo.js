$(function() {
    $.fn.editable.defaults.mode = 'inline';

    Handlebars.registerHelper('api_category_path', function (id) {
        return Routes.api_category_path(id);
    });

    var bindCategoryTitle = function (i) {
        $('#category-title-' + i).editable({ toggle: 'manual' });
        $('#category-edit-' + i).click(function (e) {
            e.stopPropagation();
            $('#category-title-' + i).editable('toggle');
        });
    };

    var bindCategoryDelete = function (i) {
        $('#category-delete-' + i).click(function() {
            var self = this;
            var url = $(self).data('url');
            $.ajax({
                url: url,
                type: 'DELETE',
                success: function() {
                    $(self).closest('.panel').remove();
                },
                error: function(err) {
                    alert(err.responseText);
                }
            });
        });
    }

    $.get(Routes.api_categories_path(), function(res) {
        var temp = $('#temp');
        temp.html(HandlebarsTemplates['categories/index'](res));

        $('.category-title').each(function (i) {
            bindCategoryTitle(i);
        });

        $('.category-delete').each(function(i, obj) {
            bindCategoryDelete(i, obj);
        });

        $('#new-category-name').editable({
            url: Routes.api_categories_path(),
            ajaxOptions: {
                type: 'post'
            },
            emptytext: '!fdfdfdfdfdfdf!!',
            emptyclass: 'custom-editable-empty',
            validate: function (value) {
                if ($.trim(value) == '') return 'Необходимо заполнить это поле';
            },
            display: function(value, sourceData) {
                if (sourceData) {
                    $(this).data('editable').setValue(null);
                    $('#msg').removeClass('alert-error').html('').hide();
                    $(this).removeClass('editable-unsaved');
                    var context = { category: sourceData, index: $('.category-title').size() }
                    $('#categories').append(HandlebarsTemplates['categories/show'](context));
                    bindCategoryTitle(context.index);
                    bindCategoryDelete(context.index);
                    $('#new-category').collapse('toggle');
                }
            }
        });

        $('#click-btn').click(function () {
            $('#new-category-name').editable('submit', {
                ajaxOptions: {
                    type: 'post',
                    beforeSend: function (xhr, settings) {
                        var data = $.deparam(settings.data);
                        data.authenticity_token = $('meta[name=csrf-token]').attr('content');
                        settings.data = $.param(data);
                        return true;
                    }
                },
                success: function (response) {
                    $('#msg').removeClass('alert-error').html('').hide();
                    $(this).editable('setValue', null);
                    $(this).removeClass('editable-unsaved');
                    var context = { category: response, index: $('.category-title').size() }
                    $('#categories').append(HandlebarsTemplates['categories/show'](context));
                    bindCategory(context.index);
                    $('#new-category').collapse('toggle');
                },
                error: function(errors) {
                    var msg = '';
                    if(errors && errors.responseText) { //ajax error, errors = xhr object
                        msg = errors.responseText;
                    } else { //validation error (client-side or server-side)
                        $.each(errors, function(k, v) { msg += k+": "+v+"<br>"; });
                    }
                    $('#msg').removeClass('alert-success').addClass('alert-danger').html(msg).show();
                }
            });
        });
    });
});