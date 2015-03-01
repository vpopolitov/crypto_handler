var signed_in = false;

$(function() {
    $.fn.editable.defaults.mode = 'inline';

    Handlebars.registerHelper('api_category_path', function (id) {
        return Routes.api_category_path(id);
    });

    Handlebars.registerHelper('api_video_path', function (id) {
        return Routes.api_video_path(id);
    });

    $('.category-title').editable({ toggle: 'manual' });

    var newBind = function() {
        $('#categories').on('click', '.category-edit', function(e) {
            e.stopPropagation();
            $(this).closest('.panel-heading').find('.category-title').editable('toggle');
        });

        $('#categories').on('click', '.category-delete', function() {
            var self = this;
            var url = $(self).data('url');
            $.ajax({
                url: url,
                type: 'DELETE',
                success: function() {
                    $(self).closest('.item-for-delete').remove();
                },
                error: function(err) {
                    alert(err.responseText);
                }
            });
        });
    }

    var rebindAddVideo = function () {
        var video = null;
        $('.new-video-name').editable({
            source: Routes.api_videos_path,
            sourceCache: false,
            emptytext: 'Не выбрано',
            validate: function (value) {
                if ($.trim(value) == '') return 'Необходимо заполнить это поле';
            },
            url: function(params) {
                category_id = $(this).data('category-id');
                video_id = params.value;
                return $.ajax({
                    url: Routes.api_video_path(video_id),
                    data: { category_id: category_id },
                    type: 'PUT',
                    dataType: 'json'
                });
            },
            success: function(response) {
                video = response.video;
            },
            display: function (value, sourceData) {
                if (value) {
                    $(this).data('editable').setValue(null);
                    $(this).removeClass('editable-unsaved');
                    var context = { video: video, signed_in: self.signed_in, index: $('.category-title').size() }
                    $(this).closest('.videos').find('.list-group').append(HandlebarsTemplates['videos/show'](context));
                    $(this).closest('.panel-collapse').collapse('toggle');
                }
            }
        });
    }

    $.get(Routes.api_categories_path(), function(res) {
        var temp = $('#temp');
        signed_in = res.meta.signed_in;
        res.signed_in = signed_in;
        temp.html(HandlebarsTemplates['categories/index'](res));

        newBind();

        $('#new-category-name').editable({
            url: Routes.api_categories_path(),
            ajaxOptions: {
                type: 'post'
            },
            emptytext: 'Не выбрано',
            validate: function (value) {
                if ($.trim(value) == '') return 'Необходимо заполнить это поле';
            },
            display: function (value, sourceData) {
                if (sourceData) {
                    $(this).data('editable').setValue(null);
                    $('#msg').removeClass('alert-error').html('').hide();
                    $(this).removeClass('editable-unsaved');
                    var context = { category: sourceData, signed_in: self.signed_in, index: $('.category-title').size() }
                    $('#categories').append(HandlebarsTemplates['categories/show'](context));
                    $('#new-category').collapse('toggle');
                    rebindAddVideo();
                }
            }
        });

        rebindAddVideo();
    });
});