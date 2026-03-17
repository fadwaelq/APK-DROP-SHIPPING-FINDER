from rest_framework.renderers import JSONRenderer

class StandardizedJSONRenderer(JSONRenderer):
    """
    Formate toutes les réponses API selon le standard du Frontend :
    { "success": bool, "data": dict, "message": str }
    """
    def render(self, data, accepted_media_type=None, renderer_context=None):
        if renderer_context is None:
            return super().render(data, accepted_media_type, renderer_context)

        response = renderer_context.get('response')
        status_code = response.status_code
        is_success = 200 <= status_code < 300

        # Si Swagger ou DRF génère la doc, on ne modifie pas le format
        if renderer_context.get('view') and renderer_context['view'].__class__.__name__ == 'SwaggerUIView':
             return super().render(data, accepted_media_type, renderer_context)

        # Structure de base exigée par le frontend
        formatted_response = {
            "success": is_success,
            "data": None,
            "message": None
        }

        if is_success:
            # Si c'est un succès, on met les données dans "data"
            if isinstance(data, dict) and 'detail' in data:
                # Si ton API renvoyait juste {"detail": "Succès"}, on le met dans message
                formatted_response["message"] = data.pop('detail')
                formatted_response["data"] = data if data else None
            else:
                formatted_response["data"] = data
        else:
            # Si c'est une erreur (400, 401, 404, etc.)
            if isinstance(data, dict):
                # On récupère le message d'erreur de DRF
                formatted_response["message"] = data.get('detail', str(data))
            elif isinstance(data, list):
                formatted_response["message"] = str(data[0])
            else:
                formatted_response["message"] = str(data)

        return super().render(formatted_response, accepted_media_type, renderer_context)