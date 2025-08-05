from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.renderers import JSONRenderer
from .models import Product

class ProductList(APIView):
    renderer_classes = [JSONRenderer]  # 👈 Add this line

    def get(self, request):
        products = Product.objects.values('id', 'name', 'price', 'description')
        return Response(list(products))
