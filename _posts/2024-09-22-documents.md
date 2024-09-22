---
title: Documents
tags: documents
---

<ul id="document-list">
    {% for doc in site.data.documents %}
    <li>
        <a href="{{ site.baseurl }}/assets/pdfs/{{ doc.filename }}" target="_blank">{{ doc.title }}</a>
    </li>
    {% endfor %}
</ul>
