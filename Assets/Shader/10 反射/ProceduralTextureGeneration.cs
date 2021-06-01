using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class ProceduralTextureGeneration : MonoBehaviour
{
    public Material material;
    private Texture2D m_generatedTexture = null;

    // Start is called before the first frame update
    void Start()
    {
        if(material == null)
        {
            Renderer renderer = this.GetComponent<Renderer>();
            if(renderer == null)
            {
                Debug.LogError("ProceduralTextureGeneration Start Fail.gameobject has not renderer.");
                return;
            }
            material = renderer.sharedMaterial;
        }

        _UpdateMaterial();
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    private void _UpdateMaterial()
    {
        if(material != null)
        {
            m_generatedTexture = _GenerateProceduralTexture();
            material.SetTexture("_MainTex", m_generatedTexture);
        }
    }

    private Texture2D _GenerateProceduralTexture()
    {
        Texture2D proceduralTexture = new Texture2D(textureWidth, textureWidth);

        //圆和圆之间的间距
        float circleInterval = textureWidth / 4.0f;

        //圆的半径
        float radius = textureWidth / 10.0f;

        //定义模糊系数
        float edgeBlur = 1.0f / blurFactor;

        for(int w = 0;w<textureWidth;w++)
        {
            for(int h = 0;h<textureWidth;h++)
            {
                //当前像素颜色
                Color pixel = backgroundColor;

                for(int i = 0;i<3;i++)
                {
                    for (int j = 0;j<3;j++)
                    {
                        //圆心位置
                        Vector2 circleCenter = new Vector2(circleInterval * (i + 1), circleInterval * (j + 1));

                        //当前位置和圆心的距离
                        float dist = Vector2.Distance(new Vector2(w, h), circleCenter) - radius;

                        //圆的颜色和背景颜色做插值计算，距离和模糊因子控制插值
                        Color color = _MixColor(circleColor, new Color(pixel.r, pixel.g, pixel.b, 0.0f), Mathf.SmoothStep(0f, 1f, dist * edgeBlur));

                        //得到像素点
                        pixel = _MixColor(pixel, color, color.a);
                    }

                    proceduralTexture.SetPixel(w, h, pixel);
                }
            }

            proceduralTexture.Apply();
        }

        return proceduralTexture;
    }

    private Color _MixColor(Color color0, Color color1, float mixFactor)
    {
        Color mixColor = Color.white;
        mixColor.r = Mathf.Lerp(color0.r, color1.r, mixFactor);
        mixColor.g = Mathf.Lerp(color0.g, color1.g, mixFactor);
        mixColor.b = Mathf.Lerp(color0.b, color1.b, mixFactor);
        mixColor.a = Mathf.Lerp(color0.a, color1.a, mixFactor);
        return mixColor;
    }

    #region

    /// <summary>
    /// 纹理大小
    /// </summary>
    [SerializeField, SetProperty("textureWidth")]
    private int m_textureWidth = 512;
    public int textureWidth
    {
        get { return m_textureWidth; }
        set
        {
            m_textureWidth = value;
            _UpdateMaterial();
        }
    }

    /// <summary>
    /// 背景颜色
    /// </summary>
    [SerializeField, SetProperty("backgroundColor")]
    private Color m_backgroundColor = Color.white;
    public Color backgroundColor
    {
        get { return m_backgroundColor; }
        set
        {
            m_backgroundColor = value;
            _UpdateMaterial();
        }
    }
    
    /// <summary>
    /// 圆的颜色
    /// </summary>
    [SerializeField, SetProperty("circleColor")]
    private Color m_circleColor = Color.yellow;
    public Color circleColor
    {
        get { return m_circleColor; }
        set
        {
            m_circleColor = value;
            _UpdateMaterial();
        }
    }

    /// <summary>
    /// 圆边界的模糊因子
    /// </summary>
    [SerializeField, SetProperty("blurFactor")]
    private float m_blurFactor = 2.0f;
    public float blurFactor
    {
        get { return m_blurFactor; }
        set
        {
            m_blurFactor = value;
            _UpdateMaterial();
        }
    }

    #endregion
}
