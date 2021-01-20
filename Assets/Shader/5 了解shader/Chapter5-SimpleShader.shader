// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

//----------------------3----------------------
Shader "ShdaerTest/Chapter5-SimpleShader"
{
   Properties 
   {
	   _Color ("Color Tint", Color) = (1.0,1.0,1.0,1.0)
   }
	SubShader
	{
		Pass
		{
			CGPROGRAM
			#pragma vertex vert			//对应顶点处理函数
			#pragma fragment frag		//对应片元处理函数

			fixed4 _Color;				//和属性匹配的对量

			// a = application 应用
			// v = vertex shader 顶点着色器
			// 数据从MeshRenderer来
			struct a2v
			{
				float4 vertex : POSITION;		//POSITION格式 		用模型空间的顶点坐标填充变量
				float3 normal : NORMAL;			//NORMAL格式   		用模型空间的法线方向填充变量
				float4 texcoord : TEXCOORD0;	//TEXCOORD0格式 	用模型的第一套纹理坐标填充变量
			};

			struct v2f
			{
				float4 pos : SV_POSITION;		//SV_POSITION格式 	用裁剪空间的顶点坐标填充变量
				fixed3 color : COLOR0;			//COLOR0格式		颜色信息
			};

			// v 自定义结构信息
			//retrun 顶点着色器和片元着色器的交互信息
			v2f vert(a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.color = v.normal * 0.5 + fixed3(0.5,0.5,0.5); 	//根据法线控制颜色
				return o;
			}

			//return 存储到一个渲染目标 颜色
			fixed4 frag(v2f i) : SV_Target
			{
				fixed3 c = i.color;
				c *= _Color.rgb;
				return fixed4(c,1.0);
			}

			ENDCG
        }
    }
}

//----------------------2----------------------
// Shader "ShdaerTest/Chapter5-SimpleShader"
// {
   
// 	SubShader
// 	{
// 		Pass
// 		{
// 			CGPROGRAM
// 			#pragma vertex vert			//对应顶点处理函数
// 			#pragma fragment frag		//对应片元处理函数

// 			// a = application 应用
// 			// v = vertex shader 顶点着色器
// 			// 数据从MeshRenderer来
// 			struct a2v
// 			{
// 				float4 vertex : POSITION;		//POSITION格式 		用模型空间的顶点坐标填充变量
// 				float3 normal : NORMAL;			//NORMAL格式   		用模型空间的法线方向填充变量
// 				float4 texcoord : TEXCOORD0;	//TEXCOORD0格式 	用模型的第一套纹理坐标填充变量
// 			};

// 			struct v2f
// 			{
// 				float4 pos : SV_POSITION;		//SV_POSITION格式 	用裁剪空间的顶点坐标填充变量
// 				fixed3 color : COLOR0;			//COLOR0格式		颜色信息
// 			};

// 			// v 自定义结构信息
// 			//retrun 顶点着色器和片元着色器的交互信息
// 			v2f vert(a2v v)
// 			{
// 				v2f o;
// 				o.pos = UnityObjectToClipPos(v.vertex);
// 				o.color = v.normal * 0.5 + fixed3(0.5,0.5,0.5); 	//根据法线控制颜色
// 				return o;
// 			}

// 			//return 存储到一个渲染目标 颜色
// 			fixed4 frag(v2f i) : SV_Target
// 			{
// 				return fixed4(i.color,1.0);	//使用顶点着色器计算的颜色
// 			}

// 			ENDCG
//         }
//     }
// }


// -----------------------1----------------------
// Shader "ShdaerTest/Chapter5-SimpleShader"
// {
   
// 	SubShader
// 	{
// 		Pass
// 		{
// 			CGPROGRAM
// 			#pragma vertex vert			//对应顶点处理函数
// 			#pragma fragment frag		//对应片元处理函数

// 			// v 顶点空间坐标
// 			//retrun 裁剪空间位置
// 			float4 vert(float4 v:POSITION) :SV_POSITION
// 			{
// 				return UnityObjectToClipPos(v);
// 			}

// 			//return 存储到一个渲染目标 颜色
// 			fixed4 frag() : SV_Target
// 			{
// 				return fixed4(1.0,1.0,1.0,1.0);
// 			}

// 			ENDCG
//         }
//     }
// }
