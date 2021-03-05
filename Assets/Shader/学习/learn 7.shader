Shader "Custom/learn 7"
{
    Properties
    {
        _Color ("Diffuse 漫反射", Color) = (1,1,1,1)
    }
    SubShader
    {
        Tags { "LightMode" = "ForeardBase"}
        LOD 200

        CGPROGRAM

        #pragma surface surf Standard fullforwardshadows
        #pragma target 3.0

        sampler2D _MainTex;

      

        
        ENDCG
    }
    FallBack "Diffuse"
}
