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

        var prevValue = null;
        $('#new-category-0-name').editable({
//            source: [
//                {value: 1, text: 'Active', video: { id: 1, title: 'Active' }},
//                {value: 2, text: 'Blocked', video: { id: 2, title: 'Blocked' }},
//                {value: 3, text: 'Deleted', video: { id: 3, title: 'Deleted' }}
//            ],
            source: Routes.api_videos_path,
            sourceCache: false,
            validate: function (value) {
                if ($.trim(value) == '') return 'Необходимо заполнить это поле';
            },
            display: function(value, sourceData) {
                if (value && prevValue != value) {
                    prevValue = value;
                    $(this).data('editable').setValue(null);
                    $(this).removeClass('editable-unsaved');
                    selectedItem = sourceData.filter(function(i) { return i.value == value; })[0]
                    var context = { video: selectedItem.video, index: $('.category-title').size() }
                    $(this).closest('.videos').find('.list-group').append(HandlebarsTemplates['videos/show'](context));
//                    bindCategoryTitle(context.index);
//                    bindCategoryDelete(context.index);
                    $(this).closest('.panel-collapse').collapse('toggle');
                }
            }
        });
    });
});