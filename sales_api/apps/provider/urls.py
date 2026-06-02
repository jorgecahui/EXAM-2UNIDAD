from rest_framework import routers
from apps.provider.views import ProviderViewSet

router = routers.DefaultRouter()
router.register('providers', ProviderViewSet)

urlpatterns = router.urls