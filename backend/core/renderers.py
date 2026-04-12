from rest_framework.renderers import JSONRenderer

class StandardizedJSONRenderer(JSONRenderer):
    """
    Formate toutes les réponses API selon le standard du Frontend :
    { "success": bool, "data": dict, "message": str }
    """
    def render(self, data, accepted_media_type=None, renderer_context=None):
        if renderer_context is None or self._is_swagger_view(renderer_context):
            return super().render(data, accepted_media_type, renderer_context)

        is_success = 200 <= renderer_context['response'].status_code < 300
        message = None

        if is_success:
            if isinstance(data, dict) and 'detail' in data:
                message = data.pop('detail')
                data = data or None
        else:
            message = self._parse_error_message(data)
            data = None

        return super().render({
            "success": is_success,
            "data": data,
            "message": message
        }, accepted_media_type, renderer_context)

    def _is_swagger_view(self, renderer_context):
        view = renderer_context.get('view')
        return view and view.__class__.__name__ == 'SwaggerUIView'

    def _parse_error_message(self, data):
        if isinstance(data, dict):
            return data.get('detail', str(data))
        if isinstance(data, list) and data:
            return str(data[0])
        return str(data)