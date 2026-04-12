import pytest
from rest_framework.response import Response
from core.renderers import StandardizedJSONRenderer

@pytest.fixture
def renderer():
    return StandardizedJSONRenderer()

def test_render_success(renderer):
    data = {"id": 1, "name": "Test"}
    context = {"response": Response(status=200)}
    rendered = renderer.render(data, renderer_context=context)
    assert b'"success":true' in rendered
    assert b'"data":{"id":1,"name":"Test"}' in rendered

def test_render_success_with_detail(renderer):
    data = {"detail": "Action completed", "id": 1}
    context = {"response": Response(status=200)}
    rendered = renderer.render(data, renderer_context=context)
    assert b'"success":true' in rendered
    assert b'"message":"Action completed"' in rendered
    assert b'"data":{"id":1}' in rendered

def test_render_error_dict(renderer):
    data = {"detail": "Not found"}
    context = {"response": Response(status=404)}
    rendered = renderer.render(data, renderer_context=context)
    assert b'"success":false' in rendered
    assert b'"message":"Not found"' in rendered

def test_render_error_list(renderer):
    data = ["Error 1", "Error 2"]
    context = {"response": Response(status=400)}
    rendered = renderer.render(data, renderer_context=context)
    assert b'"success":false' in rendered
    assert b'"message":"Error 1"' in rendered

def test_render_swagger_view(renderer):
    class SwaggerUIView:
        pass
    
    data = {"swagger": "data"}
    context = {"response": Response(status=200), "view": SwaggerUIView()}
    rendered = renderer.render(data, renderer_context=context)
    assert b'"swagger":"data"' in rendered
    assert b'"success"' not in rendered
