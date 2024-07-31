import base64
from rest_framework import serializers
from django.conf import settings
import os
from .models import Personne

class PersonneSerializer(serializers.ModelSerializer):
    img_url = serializers.SerializerMethodField()  # Pour retourner l'URL de l'image
    image_memory = serializers.SerializerMethodField()  # Pour retourner l'image encodée en base64

    class Meta:
        model = Personne
        fields = '__all__'  # Inclure tous les champs de modèle

    def get_img_url(self, obj):
        # Retourner l'URL complète de l'image si elle existe
        if obj.img and hasattr(obj.img, 'url'):
            return self.context['request'].build_absolute_uri(obj.img.url)
        return None

    def get_image_memory(self, obj):
        # Retourner l'image sous forme d'une chaîne base64
        try:
            if obj.img and obj.img.name:
                img_path = os.path.join(settings.MEDIA_ROOT, obj.img.name)
                with open(img_path, 'rb') as img_file:
                    return base64.b64encode(img_file.read()).decode('utf-8')
        except FileNotFoundError:
            return None  # Retourner None si le fichier n'est pas trouvé

        return None  # Retourner None si aucune image n'est associée
