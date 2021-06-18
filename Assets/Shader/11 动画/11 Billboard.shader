// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "Custom/11 Billboard"
{
    Properties
    {
        _MainTex ("主纹理", 2D) = "white" {}
		_Color("环境光", Color) = (1,1,1,1)
		_VerticalBillboarding("竖立方向",Range(0,1)) = 1	//固定面向法线还是向上的方向 1=视角 0=向上
	}

	SubShader
	{
		Tags
		{
			"Queue" = "Transparent"		//队列 三维物体
			"IgnoreProjector" = "true"	//无视项目的投影
			"RenderType" = "Transparent"	//渲染类型 三维物体
			"DisableBatching" = "True"	//关闭合批
		}

		Pass
		{
			Tags{"LightMode" = "ForwardBase"}	//光照类型 向前渲染

			ZWrite Off						//关闭深度写入
			Blend SrcAlpha OneMinusSrcAlpha	//混合
			Cull Off						//关闭裁剪

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			#include "Lighting.cginc"

			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed4 _Color;
			fixed _VerticalBillboarding;

			struct a2v 
			{
				float4 vertex:POSITION;
				float4 texcoord:TEXCOORD0;
			};

			struct v2f
			{
				float4 pos:SV_POSITION;
				float2 uv:TEXCOORD0;
			};

			v2f vert(a2v v)
			{
				v2f o;

				//定义锚点 模型空间的原点
				float3 center = float3(0, 0, 0);

				//定义观察者 模型空间的视角位置
				float3 viewer = mul(unity_WorldToObject, float4(_WorldSpaceCameraPos, 1));

				//法线
				float3 normalDir = viewer - center;

				//确定垂直方向 _VerticalBillboarding：1 = 面向视角 _VerticalBillboarding：0 = 面向上
				normalDir.y = normalDir.y * _VerticalBillboarding;
				//归一化法线
				normalDir = normalize(normalDir);

				//向上的向量
				float3 upDir = abs(normalDir.y) > 0.999 ? float3(0, 0, 1) : float3(0, 1, 0);

				//向右的向量
				float3 rightDir = normalize(cross(upDir, normalDir));

				//得到最终的向上的向量
				upDir = normalize(cross(normalDir, rightDir));

				//中心位置偏移 = 顶点位置 - 中心位置
				float3 centerOffs = v.vertex.xyz - center;

				//本地位置
				float3 localPos = center;
				//本地位置 + 顶点的x向量 右向量
				localPos = localPos + rightDir * centerOffs.x;
				//本地位置 + 顶点的y向量 上向量
				localPos = localPos + upDir * centerOffs.y;
				//本地位置 + 顶点的z向量 法线
				localPos = localPos + normalDir * centerOffs.z;

				//应用空间坐标转裁剪空间坐标
				o.pos = UnityObjectToClipPos(float4(localPos, 1));

				//纹理坐标
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

				return o;
			}

			float4 frag(v2f i) :SV_Target
			{
				//纹理采样
				fixed4 c = tex2D(_MainTex,i.uv);
				//环境光
				c.rgb *= _Color.rgb;
				return c;
			}

			ENDCG

		}
    }

    FallBack "Transparent/VertexLit"
}
